# Save dirstack history to .zdirs
# adapted from:
# github.com/grml/grml-etc-core/blob/master/etc/zsh/zshrc#L1547

DIRSTACKSIZE=${DIRSTACKSIZE:-20}
DIRSTACKFILE=${DIRSTACKFILE:-${HOME}/.zdirs}

typeset -gaU PERSISTENT_DIRSTACK

if [[ -f ${DIRSTACKFILE} ]] && [[ ${#dirstack[*]} -eq 0 ]] ; then
  # Enabling NULL_GLOB via (N) weeds out any non-existing
  # directories from the saved dir-stack file.
#  dirstack=( ${(f)"$(< $DIRSTACKFILE)"}(N) )
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  # save
  PERSISTENT_DIRSTACK=( "${dirstack[@]}" )
  # "cd -" won't work after login by just setting $OLDPWD, so
#  [[ -d $dirstack[1] ]] && cd -q $dirstack[1] && cd -q $OLDPWD
fi

chpwd_functions+=(chpwd_dirpersist)
function chpwd_dirpersist ()
{
  (( $DIRSTACKSIZE <= 0 )) && return
  [[ -z $DIRSTACKFILE ]] && return
  [[ $PWD == $HOME ]] && return # remove HOME dir
  PERSISTENT_DIRSTACK=( $PWD "${(@)PERSISTENT_DIRSTACK[1,$DIRSTACKSIZE]}" )
  builtin print -l ${PERSISTENT_DIRSTACK} >! ${DIRSTACKFILE}
}
