#!/usr/bin/env bash
# Claude Code statusLine script
# Reads the statusLine JSON payload from stdin and prints a single-line status:
# pulse icon | Ctx (context window) dot-bar | Session (5h) dot-bar | Week (7d) dot-bar
# Each bar's filled dots shift green -> yellow -> red as usage climbs.

input=$(cat)

RESET=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'

# 24-bit truecolor helpers: fg/bg R G B
fg() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
bg() { printf '\033[48;2;%d;%d;%dm' "$1" "$2" "$3"; }

WHITE=$(fg 255 255 255)      # labels / percentages
ICON=$(fg 130 210 255)       # pulse icon
TRACK=$(fg 100 106 115)      # empty-dot track, dim but visible
BGEND=$'\033[49m'            # clears background only, keeps other styling
FRESET=$'\033[39;22m'        # clears fg color + bold (keeps background active)
DOT_GAP=" "                  # regular space between dots
SEP="   ${DIM}│${RESET}   "  # divider between Ctx / S / W segments

# pct_color PCT -> "R G B", vivid green at low usage fading through yellow to red at high usage
pct_color() {
  awk -v p="$1" 'BEGIN {
    if (p < 0) p = 0; if (p > 100) p = 100
    g1=80;  g2=230; g3=120   # green
    y1=255; y2=210; y3=60    # yellow
    r1=255; r2=65;  r3=65    # red
    if (p <= 50) { t = p/50;      R=g1+(y1-g1)*t; G=g2+(y2-g2)*t; B=g3+(y3-g3)*t }
    else         { t = (p-50)/50; R=y1+(r1-y1)*t; G=y2+(r2-y2)*t; B=y3+(r3-y3)*t }
    printf "%d %d %d", R, G, B
  }'
}

# bg_pct_color PCT -> "R G B", the same gradient blended low-opacity onto a dark
# base so each segment's pill tint tracks its usage but stays subtle/"transparent".
bg_pct_color() {
  awk -v p="$1" 'BEGIN {
    if (p < 0) p = 0; if (p > 100) p = 100
    g1=80;  g2=230; g3=120   # green
    y1=255; y2=210; y3=60    # yellow
    r1=255; r2=65;  r3=65    # red
    if (p <= 50) { t = p/50;      R=g1+(y1-g1)*t; G=g2+(y2-g2)*t; B=g3+(y3-g3)*t }
    else         { t = (p-50)/50; R=y1+(r1-y1)*t; G=y2+(r2-y2)*t; B=y3+(r3-y3)*t }
    base_r=28; base_g=30; base_b=36
    alpha=0.14
    printf "%d %d %d", base_r+(R-base_r)*alpha, base_g+(G-base_g)*alpha, base_b+(B-base_b)*alpha
  }'
}

# make_dots PCT WIDTH -> spaced dot bar, e.g. ●  ●  ●  ○  ○
# filled dots are colored by usage (green->yellow->red); empty dots use a dim track color.
make_dots() {
  local pct=${1%.*}
  local width=$2
  [ -z "$pct" ] && pct=0
  [ "$pct" -gt 100 ] && pct=100
  [ "$pct" -lt 0 ] && pct=0
  local color
  color=$(fg $(pct_color "$pct"))
  local filled=$(( (pct * width + 99) / 100 ))
  [ "$filled" -eq 0 ] && [ "$pct" -gt 0 ] && filled=1
  [ "$filled" -gt "$width" ] && filled=$width
  local empty=$(( width - filled ))
  local bar="" i
  for ((i = 0; i < filled; i++)); do
    [ -n "$bar" ] && bar+="$DOT_GAP"
    bar+="${BOLD}${color}●${FRESET}"
  done
  for ((i = 0; i < empty; i++)); do
    [ -n "$bar" ] && bar+="$DOT_GAP"
    bar+="${TRACK}○${FRESET}"
  done
  printf '%s' "$bar"
}

# fmt_reset EPOCH_SECONDS -> "2d 18h" / "2h 15m" / "28m" / "now"
fmt_reset() {
  local epoch=$1
  [ -z "$epoch" ] && return
  local now diff
  now=$(date +%s)
  diff=$(( epoch - now ))
  if [ "$diff" -le 0 ]; then
    echo "now"
    return
  fi
  local d=$(( diff / 86400 ))
  local h=$(( (diff % 86400) / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  if [ "$d" -gt 0 ]; then
    printf '%dd %dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then
    printf '%dh %dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset_epoch=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

limit_seg() {
  local label=$1 pct=$2 reset_epoch=$3
  [ -z "$pct" ] && return
  local dots pct_int reset_str content seg_bg
  dots=$(make_dots "$pct" 9)
  pct_int=${pct%.*}
  reset_str=$(fmt_reset "$reset_epoch")
  seg_bg=$(bg $(bg_pct_color "$pct"))
  content=$(printf '%s%s%s%s:%s %s %s%3s%%%s' "$BOLD" "$WHITE" "$label" "$FRESET" "$FRESET" "$dots" "$BOLD$WHITE" "$pct_int" "$FRESET")
  [ -n "$reset_str" ] && content="${content}$(printf ' %s·%s %s' "$DIM" "$FRESET" "$reset_str")"
  printf '%s %s %s%s' "$seg_bg" "$content" "$FRESET" "$BGEND"
}

ctx_seg=$(limit_seg "Ctx" "$ctx_pct" "")
five_seg=$(limit_seg "S" "$five_pct" "$five_reset_epoch")
week_seg=$(limit_seg "W" "$week_pct" "$week_reset_epoch")

line="${BOLD}${ICON}∿${RESET}"
[ -n "$ctx_seg" ] && line="${line}${SEP}${ctx_seg}"
[ -n "$five_seg" ] && line="${line}${SEP}${five_seg}"
[ -n "$week_seg" ] && line="${line}${SEP}${week_seg}"

printf '%s\n' "$line"

exit 0
