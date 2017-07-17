# zsh-theme

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

# For root flag
os=$(uname -o)
if [[ "$os" == "Cygwin" ]]; then
    root=$(id -G)
    # 544 is windows administrators group
    if [[ $root =~ "544" ]]; then
        local root_status="#"
    else
        local root_status="$"
    fi
else
    local root_status="%(!.#.$)"
fi

local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"

PROMPT='%{${ret_status}%} %{$fg[magenta]%}%c %{$fg[yellow]%}%{${root_status}%}%{$reset_color%} '

#rprompt_context () {
#    if [[ -n "$SSH_CLIENT" ]]; then
#        echo -n "%{$fg[magenta]%}[%n@%m]%{$reset_color%}"
#    else
#        echo -n "%{$fg[magenta]%}[%D{%H:%M}]%{$reset_color%}"
#    fi
#}
#
#RPROMPT='$(rprompt_context)'
