#!/bin/sh

# group the windows by spaces
windows_group_by_spaces=$(yabai -m query --windows | jq 'group_by(.space)')

specified_window_id=$1

echo "specified_window_id=$specified_window_id"

stack_all() {
  # loop for each space in the group, encode it by base64 to avoid incorrect elements.
  for space in $(echo "${windows_group_by_spaces}" | jq -r '.[] | @base64'); do
    count=0

    # decode the space first, then loop through windows in space and encode them as the same.
    for window in $(echo "${space}" | base64 --decode | jq -r '.[] | @base64'); do
      echo "count=$count"
      _jq() {
        echo ${window} | base64 --decode | jq -r ${1}
      }

      if [[ $(_jq '.app') == 'Hammerspoon' || $(_jq '."stack-index"') -ne 0 || $(_jq '."is-floating"') == "true" ]] ; then
        continue
      elif [[ $count -eq 0 ]] ; then
        first_window_id=$(_jq '.id')
      elif [[ $count -eq 1 ]] ; then
        second_window_id=$(_jq '.id')
      else
        if [[ $(expr $count % 2) -eq 0 ]] ; then
          current_window_id=$(_jq '.id')
          yabai -m window $first_window_id --stack $current_window_id
        else
          current_window_id=$(_jq '.id')
          yabai -m window $second_window_id --stack $current_window_id
        fi
      fi

      ((count=count+1))
    done
  done
}

stack_by_wid() {
  specify_window=$(yabai -m query --windows --window $specified_window_id)

  if [[ $(echo "$specify_window" | jq -r '."is-floating"') == "false" ]] ; then
    return
  fi

  current_space_id=$(echo "$specify_window" | jq -r '.space')

  echo "---> current_space_id=$current_space_id"

  windows_in_current_space=$(yabai -m query --windows | jq -c '[.[] | select( .space|tostring == "$current_space_id" and .app != "Hammerspoon" and .id|tostring != "$specified_window_id" )]')

  echo "windows_in_current_space=$windows_in_current_space\n"

  first_window=$(echo "$windows_in_current_space" | jq '.[0]')
  first_window_id=$(echo "$first_window" | jq -r '.id')

  second_window=$(echo "$windows_in_current_space" | jq '.[1]')
  second_window_id=$(echo "$second_window" | jq -r '.id')

  if [[ $(expr $specified_window_id % 2) -ne 0 ]] ; then
    yabai -m window $first_window_id --stack $specified_window_id
  else
    yabai -m window $second_window_id --stack $specified_window_id
  fi
}

if [[ -z "$specified_window_id" ]] ; then
  echo "---> stack all\n"
  stack_all
else
  echo "---> stack by id=$specified_window_id\n"
  stack_by_wid
fi
