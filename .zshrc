
# prof start
#zmodload zsh/zprof

# language environment
# locale priority: LC_ALL > LC_* > LANG
export LANG=en_US.UTF-8
#export LC_ALL=C

# Editor
export EDITOR='vim'

# Add my PATH (Must be in front of executed tmux)
if [[ "$OSTYPE" == "cygwin" ]]; then
    ePATH=$HOME/.dotfiles/.bin:$HOME/.dotfiles/.bin/windows
else
    ePATH=$HOME/.dotfiles/.bin:$HOME/.dotfiles/.bin/linux
fi
if [[ "$PATH" != "$ePATH"* ]]; then
    export PATH=$ePATH:$PATH
fi

# Auto startup tmux
#[[ -z "$TMUX" && -n ${commands[tmux]} ]] && exec tmux
if [[ -f "/tmp/.notmux.tmp" ]]; then
    rm -f /tmp/.notmux.tmp
else
    if [[ -z "$NOTMUX" && -z "$TMUX" && -n ${commands[tmux]} ]]; then
        tmux_ls=$(tmux ls 2>/dev/null)
        # FIXME: workaround cygwin tmux
        if [[ "$tmux_ls" && "$OSTYPE" =~ "cygwin" && "$(echo $tmux_ls | wc -l)" == "6" ]]; then
            echo "Warning: tmux can only open up to 6 sessions in cygwin"
        else
            # try to reattach sessions
            (echo -n $tmux_ls | grep -vq attached) && exec tmux attach-session -d || exec tmux
        fi
    fi
fi

# LS colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=30;43:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.dotfiles/.oh-my-zsh

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
ZSH_CUSTOM=$HOME/.dotfiles/.oh-lq-zsh

# zsh-completions
source $ZSH_CUSTOM/plugins/zsh-completions/zsh-completions.plugin.zsh
source $ZSH_CUSTOM/plugins/zsh-completions-lq/zsh-completions-lq.plugin.zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    vi-mode
    extract
    dircycle
    zsh-fzf
    pip
    zsh-syntax-highlighting
    zsh-history-substring-search
)

# Run oh-my-zsh
source $ZSH/oh-my-zsh.sh

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
#export REPORTTIME=4
export TIMEFMT="$fg[green]%J: $fg[yellow]%*Es $fg[cyan](cpu=%P user=%U kernel=%S)$reset_color"

## pager
export PAGER='less'
export LESS='-R -x4 -j.3'

# default open with $EDITER
alias -s {c,cc,cpp,h,hpp,asm,s,java,bin,hex,map,dis,sct,symdefs,mk,mak,ini,log,md,xml,txt}=$EDITOR

# fix git files completion slowly in windows file system
if [[ "$OSTYPE" == "cygwin" ]]; then
    __git_files () { _wanted files expl 'local files' _files }
    __git_changed_files () { _wanted files expl 'local files' _files }
    __git_changed-in-working-tree_files () { _wanted files expl 'local files' _files }
    __git_changed-in-index_files () { _wanted files expl 'local files' _files }
fi

# General shell config
source ~/.dotfiles/.gshrc

# prof finish
#zprof

