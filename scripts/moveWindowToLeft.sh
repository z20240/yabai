#!/bin/sh
inputAction=$1

case $inputAction in
'display')
  yabai -m window --display prev --focus 2>/dev/null || yabai -m window --display last --focus
  ;;
'space')
  sh ~/.config/yabai/scripts/moveWindowOnDisplaySpace.sh prev
  ;;
*)
  wid=$(yabai -m query --windows --window | jq -re '.id')
  sh ~/.config/yabai/scripts/moveWindowToSpace.sh "$wid" "$inputAction"
  ;;
esac
