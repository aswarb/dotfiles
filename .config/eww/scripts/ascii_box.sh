#!/usr/bin/env bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

draw_box() {
  local title="$1"; shift
  local lines=("$@")

  # find max width among content and title (ensure at least one dash after title)
  local max=${#title}
  for l in "${lines[@]}"; do
    (( ${#l} > max )) && max=${#l}
  done
  (( max < ${#title} + 1 )) && max=$(( ${#title} + 1 ))

  local inner_width=$max
  local total_width=$(( inner_width + 4 ))   # total chars per line

  # compute how many '─' go after "┌─ Title "
  local dash_count=$(( total_width - ${#title} - 5 ))  # 5 = '┌' + '─' + ' ' (3) + trailing space before dashes (1) + '┐' (1)
  (( dash_count < 1 )) && dash_count=1

  # build top
  local top="┌─ $title "
  for ((i=0;i<dash_count;i++)); do top+="─"; done
  top+="┐"
  echo "$top"

  # content
  for l in "${lines[@]}"; do
    printf "│ %-*s │\n" "$inner_width" "$l"
  done

  # bottom: total_width characters long
  local bottom="└"
  for ((i=0;i<total_width-2;i++)); do bottom+="─"; done
  bottom+="┘"
  echo "$bottom"
}

draw_box "$@"

