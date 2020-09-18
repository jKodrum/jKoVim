alias ll="ls -ahl"
alias la="ls -hl"
alias tmux="tmux -2"
export CLICOLOR="true"
export LSCOLORS="gxfxcxdxcxegedabagacad"

# PS1='\h:\W \u\$ '
my_prompt() {
    local COLOR_RESET='\[\033[m\]'
    local COLOR_BRANCH='\[\033[38;5;28m\]'
    local BRANCH=$(git branch 2> /dev/null | grep "*" | sed -e "s:\* ::g")

    if [ -n "$BRANCH" ]; then
        BRANCH="($COLOR_BRANCH$BRANCH$COLOR_RESET) "
    fi

    PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $BRANCH\$ "
}

PROMPT_COMMAND=my_prompt
