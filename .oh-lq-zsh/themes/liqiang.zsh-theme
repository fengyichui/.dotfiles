# zsh-theme

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

rprompt_context () {
    if [[ -n "$SSH_CLIENT" ]]; then
        echo -n "%{$fg[magenta]%}[%n@%m]%{$reset_color%}"
    else
        echo -n "%{$fg[magenta]%}[%*]%{$reset_color%}"
    fi
}

local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"

PROMPT='${ret_status} %{$fg[magenta]%}%c %{$fg[yellow]%}%(!.#.$)%{$reset_color%} '

RPROMPT='$(rprompt_context)'

