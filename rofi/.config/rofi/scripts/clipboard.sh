#!/usr/bin/env bash
set -uo pipefail


if pgrep -x rofi >/dev/null 2>&1; then
  pkill -x rofi
  exit 0
fi

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"
THUMB_PX=72       
MAX_ENTRIES=60    
THEME="$HOME/.config/rofi/clipboard.rasi"

mkdir -p "$CACHE"

find "$CACHE" -type f -mtime +14 -delete 2>/dev/null

mapfile -t entries < <(cliphist list 2>/dev/null | head -n "$MAX_ENTRIES")
[ "${#entries[@]}" -eq 0 ] && exit 0

build_menu() {
  local line id preview thumb
  for line in "${entries[@]}"; do
    id=${line%%$'\t'*}
    preview=${line#*$'\t'}
    if [[ "$line" == *"binary data"* ]]; then
      thumb="$CACHE/${id}.png"
      if [ ! -s "$thumb" ]; then
        printf '%s' "$line" | cliphist decode 2>/dev/null \
          | ffmpeg -y -loglevel error -i - -vf "scale=${THUMB_PX}:-1" "$thumb" 2>/dev/null
      fi
      if [ -s "$thumb" ]; then
        
        if [[ "$preview" =~ binary\ data\ ([0-9.]+\ [KMG]iB)\ ([a-z]+)\ ([0-9]+x[0-9]+) ]]; then
          preview="${BASH_REMATCH[2]}  ·  ${BASH_REMATCH[3]}  ·  ${BASH_REMATCH[1]}"
        fi
        printf '%s\0icon\x1f%s\n' "$preview" "$thumb"
        continue
      fi
    fi
    printf '%s\n' "$preview"
  done
}


row=0
while :; do
  index=$(build_menu | rofi -dmenu \
            -show-icons \
            -format i \
            -no-custom \
            -theme "$THEME" \
            -p "clip" \
            -selected-row "$row" \
            -kb-remove-char-forward "Control+d" \
            -kb-custom-1 "Delete")
  rc=$?


  [[ "$index" =~ ^[0-9]+$ ]] || exit 0
  [ "$index" -lt "${#entries[@]}" ] || exit 0

  case "$rc" in
    0)
      printf '%s' "${entries[$index]}" | cliphist decode | wl-copy
      exit 0
      ;;
    10)
      
      id=${entries[$index]%%$'\t'*}
      printf '%s' "${entries[$index]}" | cliphist delete
      rm -f "$CACHE/${id}.png"
      mapfile -t entries < <(cliphist list 2>/dev/null | head -n "$MAX_ENTRIES")
      [ "${#entries[@]}" -eq 0 ] && exit 0
      row=$index
      [ "$row" -ge "${#entries[@]}" ] && row=$(( ${#entries[@]} - 1 ))
      ;;
    *)
      exit 0
      ;;
  esac
done
