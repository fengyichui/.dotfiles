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
RPROMPT='%F{241}${rprompt}%F{reset}'

# Outputs the name of the current project
function prompt_git_current_project() {
    local dir
    dir=$(git rev-parse --show-toplevel 2>/dev/null)
    [[ $? != 0 ]] && return
    basename "$dir"
}

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

# Output git current info
function prompt_git_current_info() {
    local project
    project=$(prompt_git_current_project)
    [[ -z "$project" ]] && return

    local branch
    branch=$(prompt_git_current_branch)
    [[ -z "$branch" ]] && return

    echo "${project}·${branch}"
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
            kill -s HUP $1 &>/dev/null || :
        fi

        # generate prompt
        git_current_info="$(prompt_git_current_info)"
        tmp_prompt="export GIT_CURRENT_INFO='$git_current_info';rprompt='$git_current_info'"
        # save to temp file
        echo "$tmp_prompt" > "${HOME}/.zsh_tmp_prompt"
        # valid flag
        echo "#;" >> "${HOME}/.zsh_tmp_prompt"

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
    # try 10 times
    local i
    for i in {1..10}; do
        # read from temp file
        tmp_prompt=$(cat "${HOME}/.zsh_tmp_prompt" 2>/dev/null)
        # make sure the data is valid
        if [[ "${tmp_prompt:(-2)}" == "#;" ]]; then
            # execute it
            eval "$tmp_prompt"
            break
        fi
        sleep 0.01
    done

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

