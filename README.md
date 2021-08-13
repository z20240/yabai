# Yabai and Skhd Config

This repository contains my standalone Yabai and Skhd configurations.

## Installation

```shell
# Remove previous links
$ rm -f "${HOME}"/.{yabai,skhd}rc

# Install configs
$ git clone https://github.com/z20240/yabai.git "${HOME}"/.config/yabai
$ ln -s "${HOME}/.config/yabai/yabai/yabairc" "${HOME}/.yabairc"
$ ln -s "${HOME}/.config/yabai/skhd/skhdrc" "${HOME}/.skhdrc"
```
