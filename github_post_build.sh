#!/bin/bash
set -euo pipefail

OUTFILE="${OUTFILE:-frames.json}"

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g' -e 's/\t/\\t/g' -e 's/\r/\\r/g'
}

to_title_case() {
  # Convert string to Title Case (handles underscores and hyphens)
  echo "$1" | tr '_-' ' ' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) tolower(substr($i,2)) }}1'
}

OS=$(uname)
TMP="$(mktemp)"

get_files() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git ls-files '*.html' 2>/dev/null | grep -v '^index\.html$'
  else
    shopt -s nullglob
    for f in *.html; do
      [ -f "$f" ] || continue
      [ "$f" = "index.html" ] && continue
      printf '%s\n' "$f"
    done
  fi
}

file_epoch() {
  local file=$1
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local ts
    ts=$(git log -1 --format='%ct' -- "$file" 2>/dev/null || true)
    if [ -n "$ts" ]; then
      printf '%s' "$ts"
      return
    fi
  fi

  if [ "$OS" = "Darwin" ]; then
    stat -f "%m" "$file"
  else
    stat -c "%Y" "$file"
  fi
}

while IFS= read -r file; do
  epoch=$(file_epoch "$file")
  printf '%s\t%s\n' "$epoch" "$file"
done < <(get_files) | sort -nr > "$TMP"

printf '[\n' > "$OUTFILE"
first=1

while IFS=$'\t' read -r epoch file; do
  if [ "$OS" = "Darwin" ]; then
    ts=$(date -u -r "$epoch" +"%Y-%m-%dT%H:%M:%SZ")
  else
    ts=$(date -u -d "@$epoch" +"%Y-%m-%dT%H:%M:%SZ")
  fi

  base="${file%.*}"
  title=$(to_title_case "$base")
  title_esc=$(printf '%s' "$title" | json_escape)
  url="./$file"
  url_esc=$(printf '%s' "$url" | json_escape)

  if [ $first -eq 0 ]; then
    printf ',\n' >> "$OUTFILE"
  fi
  first=0

  printf '  {"title":"%s","url":"%s","timestamp":"%s"}' "$title_esc" "$url_esc" "$ts" >> "$OUTFILE"
done < "$TMP"

printf '\n]\n' >> "$OUTFILE"
cat "$OUTFILE"
rm -f "$TMP"
