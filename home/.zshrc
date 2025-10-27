#!/bin/bash

#   $$\               $$\   $$\           $$\        $$$$$$\              $$\
#   $$ |              $$ |  $$ |          $$ |      $$$ __$$\             $$ |
# $$$$$$\    $$$$$$\  $$ |  $$ | $$$$$$\  $$$$$$$\  $$$$\ $$ | $$$$$$$\ $$$$$$\
# \_$$  _|  $$  __$$\ $$$$$$$$ |$$  __$$\ $$  __$$\ $$\$$\$$ |$$  _____|\_$$  _|
#   $$ |    $$$$$$$$ |\_____$$ |$$ /  $$ |$$ |  $$ |$$ \$$$$ |\$$$$$$\    $$ |
#   $$ |$$\ $$   ____|      $$ |$$ |  $$ |$$ |  $$ |$$ |\$$$ | \____$$\   $$ |$$\
#   \$$$$  |\$$$$$$$\       $$ |\$$$$$$$ |$$ |  $$ |\$$$$$$  /$$$$$$$  |  \$$$$  |
#    \____/  \_______|      \__| \____$$ |\__|  \__| \______/ \_______/    \____/
#                               $$\   $$ |
#                               \$$$$$$  |
#                                \______/


# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=/bin/nvim

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting docker-compose docker golang magic-enter extract )
source $ZSH/oh-my-zsh.sh

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
# defaults
MAGIC_ENTER_GIT_COMMAND='git status -u .'
MAGIC_ENTER_OTHER_COMMAND='ls -lh .'

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#te4gh0st logo in start
~/.te4gh0st/te4gh0st

alias ports="sudo lsof -nP -iTCP -sTCP:LISTEN"
