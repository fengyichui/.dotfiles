# zsh-theme

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

# For root flag
local root_status="%(!.#.$)"
if [[ -n "$SSH_CONNECTION" ]]; then
    local ret_status="%(?:%{$fg[green]%}«:%{$fg[red]%}«)"
else
    local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"
fi
setopt PROMPT_SUBST

PROMPT='${ret_status} %{$fg[magenta]%}%c %{$fg[yellow]%}${root_status}%{$reset_color%} '

function prompt_update () {
    # for root flag
    if [[ "$OSTYPE" =~ "cygwin" ]]; then
        root=$(id -G)
        # 544 is windows administrators group
        if [[ $root =~ "544" ]]; then
            root_status="#"
        else
            root_status="$"
        fi
    else
        root_status="%(!.#.$)"
    fi
}

