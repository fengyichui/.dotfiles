# Key bindings
# ------------
if [[ $- == *i* ]]; then

__fzfcmd() {
#  echo "fzf-tmux +2 -e -d${FZF_TMUX_HEIGHT:-40%}"
  echo "fzf +2 -e"
}

# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
    (git ls-files 2>/dev/null || \
     find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune -o -type f -print -o -type d -print -o -type l -print 2>/dev/null | sed 1d | cut -b3-) \
        | $(__fzfcmd) -m | while read item; do
    echo -n "${(q)item} "
  done
  echo
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  zle redisplay
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget

# CTRL-G - Paste the selected git status file path(s) into the command line
__gsel() {
  (git status --short ./ 2>/dev/null || echo "M NOT-A-GIT-REPOSITORY") | awk '{print $2}' | $(__fzfcmd) -m | while read item; do
    echo -n "${(q)item} "
  done
  echo
}

fzf-git-widget() {
  LBUFFER="${LBUFFER}$(__gsel)"
  zle redisplay
}
zle     -N   fzf-git-widget
bindkey '^G' fzf-git-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | sed 1d | cut -b3-"}"
  cd "${$(eval "$cmd" | $(__fzfcmd) +m):-.}"
  zle reset-prompt
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  selected=( $(fc -l 1 | $(__fzfcmd) +s --tac +m -n2..,.. --tiebreak=index --toggle-sort=ctrl-r ${=FZF_CTRL_R_OPTS} -q "${LBUFFER//$/\\$}") )
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle redisplay
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

# CTRL-X - favorite in ~/.f
__favorite() {
  (grep -v '^\s*#\|^\s*$' ~/.f 2>/dev/null || echo "# No '~/.f' file") | $(__fzfcmd) -m | while read item; do
    echo -n "${item} "
  done
  echo
}

fzf-favorite-widget() {
  LBUFFER="${LBUFFER}$(__favorite)"
  zle redisplay
}
zle     -N   fzf-favorite-widget
bindkey '^X' fzf-favorite-widget

fi

