#
# change from oh-my-zsh
# by liqiang
#

# Updates editor information when the keymap changes.
function zle-keymap-select zle-line-init
{
    if [[ "$TERM" =~ "xterm" ]]; then
        case $KEYMAP in
            vicmd)      echo -ne "\e[1 q";;
            viins|main) echo -ne "\e[5 q";;
        esac
    fi

    zle reset-prompt
    zle -R
}

function zle-line-finish
{
    if [[ "$TERM" =~ "xterm" ]]; then
        echo -ne "\e[5 q"
    fi
}

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle &&  zle -R
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N edit-command-line

bindkey -v

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line

# allow ctrl-r to perform backward search in history
bindkey '^r' history-incremental-search-backward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# home end delete
bindkey "\e[3~" delete-char
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

