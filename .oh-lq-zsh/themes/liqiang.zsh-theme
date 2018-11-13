# zsh-theme

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

# For root flag
local root_status="%(!.#.$)"
local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"

setopt PROMPT_SUBST

PROMPT='${ret_status} %{$fg[magenta]%}%c %{$fg[yellow]%}${root_status}%{$reset_color%} '

rprompt_ssh_context () {
    echo -n "%{$fg[magenta]%}[%n@%m]%{$reset_color%}"
}

if [[ -n "$SSH_CLIENT" ]]; then
    RPROMPT='$(rprompt_ssh_context)'
fi

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

