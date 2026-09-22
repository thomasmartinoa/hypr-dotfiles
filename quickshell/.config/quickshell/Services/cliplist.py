#!/usr/bin/env python3
"""cliphist list → one JSON object per line for Services/Clip.qml.

One process for the whole list (the old bash loop spawned python per entry
and took seconds). Image entries get a 72px thumbnail rendered with ffmpeg
into $C, only when it is not already cached.
"""
import json, os, re, subprocess, sys, time

cache = os.environ.get("C") or os.path.expanduser("~/.cache/cliphist-thumbs")
limit = int(sys.argv[1]) if len(sys.argv) > 1 else 80
os.makedirs(cache, exist_ok=True)

# prune thumbnails older than two weeks
cutoff = time.time() - 14 * 86400
for f in os.listdir(cache):
    p = os.path.join(cache, f)
    try:
        if os.path.getmtime(p) < cutoff:
            os.remove(p)
    except OSError:
        pass

out = subprocess.run(["cliphist", "list"], capture_output=True).stdout
meta_re = re.compile(rb"binary data ([0-9.]+ [KMG]iB) ([a-z]+) ([0-9]+x[0-9]+)")
for line in out.split(b"\n")[:limit]:
    if b"\t" not in line:
        continue
    cid, preview = line.split(b"\t", 1)
    cid = cid.decode()
    if b"binary data" in preview:
        thumb = os.path.join(cache, cid + ".png")
        if not os.path.exists(thumb) or os.path.getsize(thumb) == 0:
            with subprocess.Popen(["cliphist", "decode", cid], stdout=subprocess.PIPE) as dec:
                subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", "-", "-vf", "scale=72:-1", thumb],
                               stdin=dec.stdout, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        m = meta_re.search(preview)
        meta = f"{m[2].decode()}  ·  {m[3].decode()}  ·  {m[1].decode()}" if m else preview.decode("utf-8", "replace")
        print(json.dumps({"id": int(cid), "image": True, "thumb": thumb, "preview": meta}))
    else:
        print(json.dumps({"id": int(cid), "image": False, "preview": preview.decode("utf-8", "replace")}))
