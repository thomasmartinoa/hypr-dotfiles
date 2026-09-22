#!/usr/bin/env python3
"""hypr-agent usage-update — collect coding-agent usage into one JSON file.

Writes ~/.local/state/hypr-theme/agents.json:
  {
    "updated": <epoch>,
    "accounts": [ { id, name, plan, limits: [ {name, percent, resets_at} ],
                    extra: {enabled, used, limit} | null, error } ],
    "tokens": { "days": [ {date, total, output} ... 7 ], "models": [ {model, total, output} ] }
  }

Providers are functions returning an account dict (or None when the agent is
not set up on this machine). Add one for another agent and it appears in
the panel. Only the local credential files are read; nothing is written to
them — if a token has expired the account is reported as such, and running
the agent once refreshes it.
"""
import glob, json, os, sys, time, urllib.request
from datetime import datetime, timedelta, timezone

HOME = os.path.expanduser("~")
STATE = os.path.join(HOME, ".local/state/hypr-theme")
OUT = os.path.join(STATE, "agents.json")


# ---------------------------------------------------------------- Claude Code
def claude():
    cred = os.path.join(HOME, ".claude/.credentials.json")
    if not os.path.exists(cred):
        return None
    acct = {"id": "claude", "name": "Claude Code", "plan": "", "limits": [], "extra": None, "error": ""}
    try:
        oauth = json.load(open(cred)).get("claudeAiOauth") or {}
    except (OSError, ValueError) as e:
        acct["error"] = f"credentials unreadable: {e}"
        return acct
    plan = oauth.get("subscriptionType") or ""
    acct["plan"] = {"pro": "Pro", "max": "Max", "team": "Team", "enterprise": "Enterprise"}.get(plan, plan.title())
    token = oauth.get("accessToken")
    if not token:
        acct["error"] = "not logged in — run claude"
        return acct
    if oauth.get("expiresAt", 0) / 1000 < time.time():
        acct["error"] = "token expired — run claude once to refresh"
        return acct
    req = urllib.request.Request(
        "https://api.anthropic.com/api/oauth/usage",
        headers={"Authorization": f"Bearer {token}", "anthropic-beta": "oauth-2025-04-20",
                 "Accept": "application/json", "User-Agent": "hypr-agent"})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            d = json.load(r)
    except Exception as e:  # network, 401, …
        acct["error"] = f"usage unavailable: {getattr(e, 'code', '') or e}"
        return acct
    names = {"five_hour": "Session (5h)", "seven_day": "Weekly", "seven_day_opus": "Weekly · Opus",
             "seven_day_sonnet": "Weekly · Sonnet", "seven_day_oauth_apps": "Weekly · apps"}
    for key, label in names.items():
        v = d.get(key)
        if isinstance(v, dict) and v.get("utilization") is not None:
            acct["limits"].append({"name": label, "percent": round(v["utilization"]),
                                   "resets_at": v.get("resets_at") or ""})
    x = d.get("extra_usage") or {}
    if x.get("is_enabled"):
        acct["extra"] = {"enabled": True, "used": x.get("used_credits"), "limit": x.get("monthly_limit"),
                         "percent": x.get("utilization"), "currency": x.get("currency") or "USD"}
    return acct


# --------------------------------------------------- local token counts (Claude)
def claude_tokens(days=7):
    """Sum token usage from Claude Code's transcripts (~/.claude/projects),
    by day and by model, over the last `days` days. Streams are written as
    several lines per response sharing a requestId, so count each once."""
    since = datetime.now(timezone.utc) - timedelta(days=days)
    since_s = since.timestamp()
    by_day, by_model, seen = {}, {}, set()
    for f in glob.glob(os.path.join(HOME, ".claude/projects/*/*.jsonl")):
        try:
            if os.path.getmtime(f) < since_s:
                continue
            with open(f, "rb") as fh:
                for line in fh:
                    if b'"usage"' not in line:
                        continue
                    try:
                        e = json.loads(line)
                    except ValueError:
                        continue
                    m = e.get("message") or {}
                    u = m.get("usage")
                    if not u or e.get("type") != "assistant":
                        continue
                    key = e.get("requestId") or m.get("id")
                    if key in seen:
                        continue
                    seen.add(key)
                    ts = e.get("timestamp", "")
                    try:
                        t = datetime.fromisoformat(ts.replace("Z", "+00:00"))
                    except ValueError:
                        continue
                    if t < since:
                        continue
                    out = u.get("output_tokens", 0)
                    total = (u.get("input_tokens", 0) + out + u.get("cache_read_input_tokens", 0)
                             + u.get("cache_creation_input_tokens", 0))
                    day = t.astimezone().strftime("%Y-%m-%d")
                    dd = by_day.setdefault(day, {"date": day, "total": 0, "output": 0})
                    dd["total"] += total; dd["output"] += out
                    model = (m.get("model") or "unknown").replace("claude-", "")
                    if model.startswith("<"):   # <synthetic> — no tokens
                        continue
                    mm = by_model.setdefault(model, {"model": model, "total": 0, "output": 0})
                    mm["total"] += total; mm["output"] += out
        except OSError:
            continue
    today = datetime.now().date()
    days_out = []
    for i in range(days - 1, -1, -1):
        d = (today - timedelta(days=i)).strftime("%Y-%m-%d")
        days_out.append(by_day.get(d, {"date": d, "total": 0, "output": 0}))
    models = sorted(by_model.values(), key=lambda x: -x["total"])
    return {"days": days_out, "models": models}


PROVIDERS = [claude]


def main():
    accounts = []
    for p in PROVIDERS:
        try:
            a = p()
        except Exception as e:
            a = {"id": p.__name__, "name": p.__name__, "plan": "", "limits": [], "extra": None, "error": str(e)}
        if a:
            accounts.append(a)
    data = {"updated": int(time.time()), "accounts": accounts, "tokens": claude_tokens()}
    os.makedirs(STATE, exist_ok=True)
    tmp = OUT + ".tmp"
    with open(tmp, "w") as fh:
        json.dump(data, fh)
    os.replace(tmp, OUT)
    if "--print" in sys.argv:
        print(json.dumps(data, indent=2))


if __name__ == "__main__":
    main()
