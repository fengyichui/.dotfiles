# zsh-theme

# For root flag
local root_status="%(!.#.$)"
# rprompt
local rprompt=''
# async procs
local async_procs=''

# For ssh flag
if [[ -n "$SSH_CONNECTION" ]]; then
    local ret_status="%(?:%{$fg[green]%}«:%{$fg[red]%}«)"
else
    local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"
fi

# parameter expansion, command substitution and arithmetic expansion are performed in prompts
setopt PROMPT_SUBST

# Set prompt (left)
PROMPT='${ret_status} %{$fg[magenta]%}%c %{$fg[yellow]%}${root_status}%{$reset_color%} '

# Set prompt (right)
RPROMPT='%{$fg[magenta]%}${rprompt}%{$reset_color%}'

# Outputs the name of the current branch
function prompt_git_current_branch() {
    local ref
    ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
    local ret=$?
    if [[ $ret != 0 ]]; then
        [[ $ret == 128 ]] && return  # no git repo.
        ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
    fi
    echo ${ref#refs/heads/}
}

# Root flag
function prompt_root_status () {
    # for root flag
    if [[ "$OSTYPE" == "cygwin" ]]; then
        group_ids=$(id -G)
        admin_sgid=$(getent group S-1-5-32-544 | sed -e 's/[^:]*:[^:]*:\([0-9]*\):.*$/\1/')
        if [ -z "$admin_sgid" ]; then
            admin_sgid=544  # 544 is windows administrators group
        fi
        if [[ $group_ids =~ "(^| )${admin_sgid}( |$)" ]]; then
            echo "#"
        else
            echo "$"
        fi
    else
        echo "%(!.#.$)"
    fi
}

# prompt update
function prompt_update () {
    # for root flag
    root_status="$(prompt_root_status)"
}

# Hook Functions: executed before each prompt
function precmd() {
    function async() {
        # kill child if necessary
        if [[ ! -z "$1" ]]; then
            kill -s HUP $1 >/dev/null 2>&1 || :
        fi

        # save to temp file
        echo "rprompt='$(prompt_git_current_branch)'" > "${HOME}/.zsh_tmp_prompt"

        # signal parent, trigger TRAPUSR1()
        kill -s USR1 $$
    }

#    [[ "$PWD" == "$HOME" ]] && return

    # start background computation
    async $async_procs &!
    async_procs="$async_procs $!"
}

# Hook Functions: trigger by `kill -s USR1 $$`
function TRAPUSR1() {
    # read from temp file
    source "${HOME}/.zsh_tmp_prompt"

    # reset proc number
    async_procs=''

    # redisplay
    zle && zle reset-prompt
}

# run TRAPALRM every $TMOUT seconds
#TMOUT=1
#TRAPALRM () {
#}

#fg[blue]
#fg[yellow]
#fg[magenta]
#fg[orange]
#fg[green]
#fg[magenta]
#fg[red]

#if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi

