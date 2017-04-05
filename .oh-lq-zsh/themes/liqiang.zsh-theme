# zsh-theme

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"

PROMPT='${ret_status} %{$fg[magenta]%}%c %{$fg[yellow]%}%(!.#.$)%{$reset_color%} '

rprompt_context () {
    if [[ -n "$SSH_CLIENT" ]]; then
        echo -n "%{$fg[magenta]%}[%n@%m]%{$reset_color%}"
    else
        echo -n "%{$fg[magenta]%}[%D{%H:%M}]%{$reset_color%}"
    fi
}

setopt PROMPT_SUBST

RPROMPT='$(rprompt_context)'

## run TRAPALRM every $TMOUT seconds
TMOUT=60
TRAPALRM () {
     zle reset-prompt
}

