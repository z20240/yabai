#!/bin/sh
# Move a window to a space, follow focus, and force it into the destination layout.

wid=$1
target=$2

src_space=$(yabai -m query --windows | jq -re --argjson wid "$wid" '.[] | select(.id == $wid) | .space')

anchor=$(
  yabai -m query --windows --space "$target" | jq -re --argjson wid "$wid" '
    [.[] | select(.id != $wid and (.["is-floating"] | not))][0].id // empty
  ' 2>/dev/null || true
)

yabai -m window --focus "$wid"

if [ "$src_space" != "$target" ]; then
  yabai -m space "$src_space" --balance 2>/dev/null
fi

yabai -m window --space "$target" --focus
sleep 0.05

if [ -n "$anchor" ]; then
  yabai -m window --focus "$wid"
  yabai -m window --warp "$anchor" 2>/dev/null
  yabai -m space "$target" --balance
else
  yabai -m space "$target" --balance
  yabai -m window --focus "$wid"

  display=$(yabai -m query --windows | jq -re --argjson wid "$wid" '.[] | select(.id == $wid) | .display')
  left_pad=$(yabai -m config left_padding)
  right_pad=$(yabai -m config right_padding)
  top_pad=$(yabai -m config top_padding)
  bottom_pad=$(yabai -m config bottom_padding)
  expected_w=$(
    yabai -m query --displays --display "$display" | jq -re --argjson lp "$left_pad" --argjson rp "$right_pad" '
      .frame.w - $lp - $rp
    '
  )
  expected_h=$(
    yabai -m query --displays --display "$display" | jq -re --argjson tp "$top_pad" --argjson bp "$bottom_pad" '
      .frame.h - $tp - $bp
    '
  )

  should_expand=$(
    yabai -m query --windows | jq -re --argjson wid "$wid" --argjson ew "$expected_w" --argjson eh "$expected_h" '
      .[] | select(.id == $wid) | (.frame.w < ($ew * 0.9)) or (.frame.h < ($eh * 0.9))
    '
  )

  if [ "$should_expand" = "true" ]; then
    is_floating=$(yabai -m query --windows | jq -re --argjson wid "$wid" '.[] | select(.id == $wid) | .["is-floating"]')
    if [ "$is_floating" = "false" ]; then
      yabai -m window --focus "$wid"
      yabai -m window --toggle float
    fi

    yabai -m window --focus "$wid"
    yabai -m window --grid 1:1:0:0:1:1

    is_floating=$(yabai -m query --windows | jq -re --argjson wid "$wid" '.[] | select(.id == $wid) | .["is-floating"]')
    if [ "$is_floating" = "true" ]; then
      yabai -m window --focus "$wid"
      yabai -m window --toggle float
    fi

    yabai -m space "$target" --balance
  fi

  is_floating=$(yabai -m query --windows | jq -re --argjson wid "$wid" '.[] | select(.id == $wid) | .["is-floating"]')
  if [ "$is_floating" = "true" ]; then
    yabai -m window --focus "$wid"
    yabai -m window --toggle float
    yabai -m space "$target" --balance
  fi
fi

yabai -m window --focus "$wid"
