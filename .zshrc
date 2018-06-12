
# Auto startup tmux
#[[ -z "$TMUX" && -n ${commands[tmux]} ]] && exec tmux
#if [[ -z "$TMUX" && -n ${commands[tmux]} ]]; then
#    # try to reattach sessions
#    TMUXARG=""
#    tmux ls 2>/dev/null | grep -vq attached && TMUXARG="attach-session -d"
#    exec eval "tmux $TMUXARG"
#fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="liqiang"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.oh-lq-zsh

# zsh-completions
source $ZSH_CUSTOM/plugins/zsh-completions/zsh-completions.plugin.zsh
source $ZSH_CUSTOM/plugins/zsh-completions-lq/zsh-completions-lq.plugin.zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    safe-paste
    vi-mode
    extract
    dircycle
    zsh-fzf
    pip
    zsh-syntax-highlighting
    zsh-history-substring-search
)

# You may need to manually set your language environment
# locale priority: LC_ALL > LC_* > LANG
export LANG=en_US.UTF-8
#export LC_ALL=C

# Editor
export EDITOR='vim'

# Run oh-my-zsh
source $ZSH/oh-my-zsh.sh

# General shell config
source ~/.gshrc

# Option
setopt NO_BEEP                   # i hate beeps
#setopt RM_STAR_WAIT              # if `rm *` wait 10 seconds before performing it!
# History
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt NO_SHARE_HISTORY          # Not share history with other window

# Show time a command took if over 4 sec
#autoload -Uz colors && colors
export REPORTTIME=4
export TIMEFMT="$fg[green]%J: $fg[yellow]%*Es $fg[cyan](cpu=%P user=%U kernel=%S)$reset_color"

# default open with $EDITER
for s in c cc cpp h hpp asm s java bin hex map dis sct symdefs mk mak ini log md xml txt; do alias -s $s=$EDITOR; done

# fix git files completion slowly
__git_files () { _wanted files expl 'local files' _files }
__git_changed_files () { _wanted files expl 'local files' _files }
