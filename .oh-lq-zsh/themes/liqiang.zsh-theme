# zsh-theme

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

# For root flag
local root_status="%(!.#.$)"

# For ssh flag
if [[ -n "$SSH_CONNECTION" ]]; then
    local ret_status="%(?:%{$fg[green]%}«:%{$fg[red]%}«)"
else
    local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"
fi

# parameter expansion, command substitution and arithmetic expansion are performed in prompts
setopt PROMPT_SUBST

# Set prompt
PROMPT='${ret_status} %{$fg[magenta]%}%c $(prompt_git_current_branch)%{$fg[yellow]%}${root_status}%{$reset_color%} '

# Outputs the name of the current branch
function prompt_git_current_branch() {
    [[ "$OSTYPE" == "cygwin" && ! -f .gitignore ]] && return # cygwin git is slow
    local ref
    ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
    [[ $? != 0 ]] && return  # no git repo.
    echo "%{$fg[blue]%}(${ref#refs/heads/}) "
}

# Root flag
function prompt_update () {
    # for root flag
    if [[ "$OSTYPE" == "cygwin" ]]; then
        group_ids=$(id -G)
        admin_sgid=$(getent group S-1-5-32-544 | sed -e 's/[^:]*:[^:]*:\([0-9]*\):.*$/\1/')
        if [ -z "$admin_sgid" ]; then
            admin_sgid=544  # 544 is windows administrators group
        fi
        if [[ $group_ids =~ "(^| )${admin_sgid}( |$)" ]]; then
            root_status="#"
        else
            root_status="$"
        fi
    else
        root_status="%(!.#.$)"
    fi
}

