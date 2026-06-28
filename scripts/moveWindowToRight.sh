#!/bin/sh
inputAction=$1

case $inputAction in
'display')
  yabai -m window --display next --focus 2>/dev/null || yabai -m window --display first --focus
  ;;
'space')
  sh ~/.config/yabai/scripts/moveWindowOnDisplaySpace.sh next
  ;;
*)
  wid=$(yabai -m query --windows --window | jq -re '.id')
  sh ~/.config/yabai/scripts/moveWindowToSpace.sh "$wid" "$inputAction"
  ;;
esac
