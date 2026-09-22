#!/usr/bin/env bash
# One poll of the numbers the bar's sysmon shows, as "key value" lines:
#   cpu <idle-jiffies> <total-jiffies>      (the bar turns two samples into %)
#   mem <used-percent>
#   gpu <busy-percent>                      only when a GPU can report it
#
# GPU sources, in order: amdgpu/i915 gpu_busy_percent in sysfs, then
# nvidia-smi — but only when the card is awake (power_state D0). Polling a
# suspended laptop dGPU wakes it up and costs battery, so an asleep card
# reports nothing and the widget hides its GPU half.
set -u

read -r _ u n s i io irq sirq st _ < /proc/stat
printf 'cpu %s %s\n' "$((i + io))" "$((u + n + s + i + io + irq + sirq + st))"

tot=0; avail=0
while read -r k v _; do
    case "$k" in MemTotal:) tot=$v ;; MemAvailable:) avail=$v ;; esac
done < /proc/meminfo
[[ $tot -gt 0 ]] && printf 'mem %s\n' "$(( 100 - 100 * avail / tot ))"

for f in /sys/class/drm/card*/device/gpu_busy_percent; do
    [[ -r "$f" ]] || continue
    printf 'gpu %s\n' "$(<"$f")"
    exit 0
done

command -v nvidia-smi >/dev/null 2>&1 || exit 0
for d in /sys/class/drm/card*/device; do
    [[ "$(cat "$d/vendor" 2>/dev/null)" == "0x10de" ]] || continue     # NVIDIA
    [[ "$(cat "$d/power_state" 2>/dev/null)" == "D0" ]] || exit 0      # asleep: leave it alone
    g="$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1)"
    [[ "$g" =~ ^[0-9]+$ ]] && printf 'gpu %s\n' "$g"
    exit 0
done
