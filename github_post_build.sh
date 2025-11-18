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

# Collect creation epoch and filename (excluding index.html)
if [ "$OS" = "Darwin" ]; then
  shopt -s nullglob
  for f in *.html; do
    [ -f "$f" ] || continue
    [ "$f" = "index.html" ] && continue
    epoch=$(stat -f "%B" "$f")
    if [ "$epoch" -eq 0 ]; then
      epoch=$(stat -f "%m" "$f")
    fi
    printf '%s\t%s\n' "$epoch" "$f"
  done | sort -n > "$TMP"
else
  shopt -s nullglob
  for f in *.html; do
    [ -f "$f" ] || continue
    [ "$f" = "index.html" ] && continue
    epoch=$(stat -c "%W" "$f")
    if [ "$epoch" -lt 0 ]; then
      epoch=$(stat -c "%Y" "$f")
    fi
    printf '%s\t%s\n' "$epoch" "$f"
  done | sort -n > "$TMP"
fi

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
