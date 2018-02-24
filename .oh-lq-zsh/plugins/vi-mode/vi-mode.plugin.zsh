#
# change from oh-my-zsh
# by liqiang
#

# Updates editor information when the keymap changes.
function zle-keymap-select zle-line-init
{
    if [[ -n "$TMUX" ]]; then
        case $KEYMAP in
            vicmd)      echo -ne "\ePtmux;\e\e[1 q\e\\";;
            viins|main) echo -ne "\ePtmux;\e\e[5 q\e\\";;
        esac
    else # if [[ "$TERM" =~ "xterm" ]]; then
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
    if [[ -n "$TMUX" ]]; then
        echo -ne "\ePtmux;\e\e[5 q\e\\"
    else # if [[ "$TERM" =~ "xterm" ]]; then
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
bindkey '^k' kill-line

# allow ctrl-r to perform backward search in history
bindkey '^r' history-incremental-search-backward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# Home End Delete
bindkey "\e[3~" delete-char             # Del  (For cygwin)
bindkey "\e[H" beginning-of-line        # Home (For cygwin)
bindkey "\e[F" end-of-line              # End  (For cygwin)
bindkey '^[[3~' delete-char             # Del
bindkey "^[[1~" beginning-of-line       # Home
bindkey "^[[4~" end-of-line             # End
bindkey '^[[2~' beep                    # Insert

# Some extra vim like bindings
bindkey -a 'gg' beginning-of-buffer-or-history
bindkey -a 'G' end-of-buffer-or-history
bindkey -a 'u' undo
bindkey -a '^R' redo

#
# Allow Copy/Paste with the system clipboard
# behave as expected with vim commands ( y/p/d/c/s )
#
# Copy
function cutbuffer()
{
    zle .$WIDGET
    echo $CUTBUFFER | clipcopy
}

zle_cut_widgets=(
    vi-backward-delete-char
    vi-change
    vi-change-eol
    vi-change-whole-line
    vi-delete
    vi-delete-char
    vi-kill-eol
    vi-substitute
    vi-yank
    vi-yank-eol
)
for widget in $zle_cut_widgets
do
    zle -N $widget cutbuffer
done

# Paste
function putbuffer()
{
    zle copy-region-as-kill "$(clippaste)"
    zle .$WIDGET
}

zle_put_widgets=(
    vi-put-after
    vi-put-before
)
for widget in $zle_put_widgets
do
    zle -N $widget putbuffer
done

