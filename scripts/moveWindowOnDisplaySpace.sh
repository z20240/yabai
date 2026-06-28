#!/bin/sh
# Move focused window to prev/next space on the same display.

direction=$1

window=$(yabai -m query --windows --window)
wid=$(echo "$window" | jq -re '.id')
cur_display=$(echo "$window" | jq -re '.display')
cur_space=$(echo "$window" | jq -re '.space')

target=$(
  yabai -m query --spaces | jq -re --arg dir "$direction" --argjson display "$cur_display" --argjson cur "$cur_space" '
    [.[] | select(.display == $display) | .index] | sort | . as $spaces |
    ($spaces | index($cur)) as $i |
    if $dir == "next" then
      if $i == ($spaces | length - 1) then $spaces[0] else $spaces[$i + 1] end
    else
      if $i == 0 then $spaces[-1] else $spaces[$i - 1] end
    end
  '
)

sh ~/.config/yabai/scripts/moveWindowToSpace.sh "$wid" "$target"
