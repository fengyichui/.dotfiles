# zsh-theme

local ret_status="%(?:%{$fg[green]%}»:%{$fg[red]%}»)"

PROMPT='${ret_status} %{$fg[magenta]%}%c %{$fg[yellow]%}%(!.#.$)%{$reset_color%} '

RPROMPT='%{$fg[magenta]%}[%*]%{$reset_color%}'

