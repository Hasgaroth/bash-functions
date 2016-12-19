#!/bin/bash
# --------------------------------------------------------------------------------
# Script name  : bash_git_aliases.sh
# Author       : Dave Rix (dave@analysisbydesign.co.uk)
# Created      : 2015-01-01
# Description  : Some useful bash config items when using Git
#              : 'source' this file from within your bash login scripts
# History      :
#  2015-01-01  : DAR - Initial script
# --------------------------------------------------------------------------------

# A simple set of aliases for short-cutting git commands

# setting the colors
if tput setaf 1 &> /dev/null; then
    tput sgr0
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
        MAGENTA=$(tput setaf 9)
        ORANGE=$(tput setaf 172)
        GREEN=$(tput setaf 190)
        PURPLE=$(tput setaf 141)
        WHITE=$(tput setaf 3)
    else
        MAGENTA=$(tput setaf 5)
        ORANGE=$(tput setaf 4)
        GREEN=$(tput setaf 2)
        PURPLE=$(tput setaf 1)
        WHITE=$(tput setaf 7)
    fi
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    MAGENTA="\033[1;31m"
    ORANGE="\033[1;33m"
    GREEN="\033[1;32m"
    PURPLE="\033[1;35m"
    WHITE="\033[1;37m"
    BOLD=""
    RESET="\033[m"
fi

export MAGENTA
export ORANGE
export GREEN
export PURPLE
export WHITE
export BOLD
export RESET

function parse_git_dirty() {
    [[ $(git status 2> /dev/null | tail -n1) != *"working directory clean"* ]] && echo "*"
}

function parse_git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

export PS1="\[${BOLD}${MAGENTA}\]\u \[$WHITE\]at \[${YELLOW}\]\h\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" on \")\[$PURPLE\]\$(parse_git_branch)\[$WHITE\]\n\[$GREEN\]\w\[$WHITE\]\$ \[$RESET\]"
export PS2="\[$ORANGE\]→ \[$RESET\]"

alias gs="git status"
alias gf="git fetch; git pull"
alias ga="git add --all"
alias gc="git commit"
alias gp="git push"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gb="echo '-- local'; git branch; echo '-- remote'; git branch --remote | grep -v \"origin/master\" | sed \"s/origin\\///\" | column"


