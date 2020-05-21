
# prof start
#zmodload zsh/zprof

# language environment
# locale priority: LC_ALL > LC_* > LANG
export LANG=en_US.UTF-8
#export LC_ALL=C

# Editor
export EDITOR='vim'

# default X-window display
export DISPLAY=':0.0'

# Add my PATH (Must be in front of executed tmux)
if [[ "$OSTYPE" == "cygwin" ]]; then
    ePATH=$HOME/.bin:$HOME/.dotfiles/.bin:$HOME/.dotfiles/.bin/windows:$HOME/.dotfiles/.bin/cygwin
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    ePATH=$HOME/.bin:$HOME/.bin.windows:$HOME/.dotfiles/.bin:$HOME/.dotfiles/.bin/windows
else
    ePATH=$HOME/.bin:$HOME/.dotfiles/.bin:$HOME/.dotfiles/.bin/linux
fi
if [[ "$PATH" != "$ePATH"* ]]; then
    export PATH=$ePATH:$PATH
fi

# Auto startup tmux
#[[ -z "$TMUX" && -n ${commands[tmux]} ]] && exec tmux
if [[ -f "/tmp/.notmux.tmp" ]]; then
    rm -f /tmp/.notmux.tmp
else
    if [[ -z "$SSH_CONNECTION" && -z "$NOTMUX" && -z "$TMUX" && -n ${commands[tmux]} ]]; then
        if [[ "$OSTYPE" == "cygwin" ]]; then
            # Disable pseudo console support in pty (issue with tmux)
            export CYGWIN=disable_pcon
            # FIXME: workaround cygwin tmux
            # https://www.cygwin.com/cygwin-ug-net/highlights.html#ov-hi-sockets :
            # AF_UNIX (AF_LOCAL) sockets are not available in Winsock. They are implemented in Cygwin by using local AF_INET sockets instead.
            if grep -q tmux /proc/[0-9]*/exename; then
                tmux_ls=$(tmux ls 2>/dev/null)
                if [[ "$(wc -l <<< $tmux_ls)" -ge "6" ]]; then
                    echo "Warning: tmux can only open up to 6 sessions in cygwin"
                else
                    (grep -vq attached <<< $tmux_ls) && exec tmux attach-session -d || exec tmux
                fi
            else
                rm -f "/tmp/tmux-$UID/default"
                exec tmux
            fi
        else
            # try to reattach sessions
            (tmux ls 2>/dev/null | grep -vq attached) && exec tmux attach-session -d || exec tmux
        fi
    fi
fi

# LS colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=30;43:st=37;44:ex=00;32:*.tar=00;31:*.tgz=00;31:*.arc=00;31:*.arj=00;31:*.taz=00;31:*.lha=00;31:*.lz4=00;31:*.lzh=00;31:*.lzma=00;31:*.tlz=00;31:*.txz=00;31:*.tzo=00;31:*.t7z=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.dz=00;31:*.gz=00;31:*.lrz=00;31:*.lz=00;31:*.lzo=00;31:*.xz=00;31:*.zst=00;31:*.tzst=00;31:*.bz2=00;31:*.bz=00;31:*.tbz=00;31:*.tbz2=00;31:*.tz=00;31:*.deb=00;31:*.rpm=00;31:*.jar=00;31:*.war=00;31:*.ear=00;31:*.sar=00;31:*.rar=00;31:*.alz=00;31:*.ace=00;31:*.zoo=00;31:*.cpio=00;31:*.7z=00;31:*.rz=00;31:*.cab=00;31:*.jpg=00;35:*.jpeg=00;35:*.mjpg=00;35:*.mjpeg=00;35:*.gif=00;35:*.bmp=00;35:*.pbm=00;35:*.pgm=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.tiff=00;35:*.png=00;35:*.svg=00;35:*.svgz=00;35:*.mng=00;35:*.pcx=00;35:*.mov=00;35:*.mpg=00;35:*.mpeg=00;35:*.m2v=00;35:*.mkv=00;35:*.webm=00;35:*.ogm=00;35:*.mp4=00;35:*.m4v=00;35:*.mp4v=00;35:*.vob=00;35:*.qt=00;35:*.nuv=00;35:*.wmv=00;35:*.asf=00;35:*.rm=00;35:*.rmvb=00;35:*.flc=00;35:*.avi=00;35:*.fli=00;35:*.flv=00;35:*.gl=00;35:*.dl=00;35:*.xcf=00;35:*.xwd=00;35:*.yuv=00;35:*.cgm=00;35:*.emf=00;35:*.ogv=00;35:*.ogx=00;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'

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
[[ -f /etc/git-extras-completion.zsh ]] && source /etc/git-extras-completion.zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    vi-mode
    zsh-fzf
    pip
    dirpersist
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
# Glob
setopt EXTENDED_GLOB             # Complete more pattern: ^x x~y x# x##

# Show time a command took if over 4 sec
#autoload -Uz colors && colors
#export REPORTTIME=4
export TIMEFMT="$fg[green]%J: $fg[yellow]%*Es $fg[cyan](cpu=%P user=%U kernel=%S)$reset_color"

## pager
export PAGER='less'
export LESS='-R -M -x4 -j.3'

# default open with $EDITER
alias -s {c,cc,cpp,h,hpp,asm,s,java,bin,hex,map,dis,sct,symdefs,mk,mak,ini,log,md,xml,txt}=$EDITOR

# General shell config
source ~/.dotfiles/.gshrc
[[ -f ~/.gshrc ]] && source ~/.gshrc

# fix git files completion slowly in windows file system
if [[ "$OSTYPE" == "cygwin" ]]; then
    __git_files () { _wanted files expl 'local files' _files }
    __git_changed_files () { _wanted files expl 'local files' _files }
    __git_changed-in-working-tree_files () { _wanted files expl 'local files' _files }
    __git_changed-in-index_files () { _wanted files expl 'local files' _files }
fi

# overwrite .gshrc __setsid function
#__setsid () { setsid --fork "$@" >/tmp/setsid.${1##*/}.log 2>&1 &! }
__setsid () { setsid "$@" >/tmp/setsid.${1##*/}.log 2>&1 &! }

# prof finish
#zprof

