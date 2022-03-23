#!/bin/sh

inputAction=$1
is_zoom_fullscree=$(yabai -m query --windows --window | jq -re '."zoom-fullscreen"')
is_floating=$(yabai -m query --windows --window | jq -re ".floating")

# if window is in fullscreen, toggle to shrink it.
if [ $is_zoom_fullscree -eq "1" ] ; then
  yabai -m window --toggle zoom-fullscreen
fi

if [ $is_floating -eq "1" ]; then
  # do move for floating mode.
  case $inputAction in
    'left')
      yabai -m window --grid 1:2:0:0:1:1
      ;;
    'right')
      yabai -m window --grid 1:2:1:0:1:1
      ;;
    'up')
      yabai -m window --grid 1:1:0:0:1:1
      ;;
    'down')
      yabai -m window --grid 12:12:1:1:9:9
      ;;
    *)
      ;;
  esac
else
  # do focus for tilling mode.
  case $inputAction in
    'left')
      yabai -m window --focus west
      ;;
    'right')
      yabai -m window --focus east
      ;;
    'up')
      yabai -m window --focus north
      ;;
    'down')
      yabai -m window --focus south
      ;;
    *)
      ;;
  esac
fi
