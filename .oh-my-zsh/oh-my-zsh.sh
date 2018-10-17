# Initializes Oh My Zsh

# add a function path
#fpath=($ZSH/functions $ZSH/completions $fpath)

# Load all stock functions (from $fpath files) called below.
autoload -U compinit # liqiang <>

# Set ZSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
if [[ -z "$ZSH_CUSTOM" ]]; then
  ZSH_CUSTOM="$ZSH/custom"
fi

# Load all of the config files in ~/oh-my-zsh that end in .zsh
# TIP: Add files you don't want in git to .gitignore
for config_file ($ZSH/lib/*.zsh); do
  custom_config_file="${ZSH_CUSTOM}/lib/${config_file:t}"
  [[ -f "${custom_config_file}" ]] && config_file=${custom_config_file}
  source $config_file
done

is_plugin() {
  local base_dir=$1
  local name=$2
  [[ -f $base_dir/plugins/$name/$name.plugin.zsh || -f $base_dir/plugins/$name/_$name ]]
}
# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if is_plugin $ZSH_CUSTOM $plugin; then
    fpath=($ZSH_CUSTOM/plugins/$plugin $fpath)
  elif is_plugin $ZSH $plugin; then
    fpath=($ZSH/plugins/$plugin $fpath)
  fi
done

# Save the location of the current completion dump file.
ZSH_COMPDUMP="${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

# On slow systems, checking the cached .zcompdump file to see if it must be 
# regenerated adds a noticable delay to zsh startup.  This little hack restricts 
# it to once a day.  It should be pasted into your own completion file.
if [[ -f "${ZSH_COMPDUMP}" ]]; then
  compinit -C -d "${ZSH_COMPDUMP}"
else
  compinit -d "${ZSH_COMPDUMP}"
fi

# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
  if [[ -f $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh ]]; then
    source $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh
  elif [[ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done

# Load all of your custom configurations from custom/
for config_file ($ZSH_CUSTOM/*.zsh(N)); do
  source $config_file
done
unset config_file

# Load the theme
if [[ ! "$ZSH_THEME" = ""  ]]; then
  if [[ -f "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme" ]]; then
    source "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme"
  elif [[ -f "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme" ]]; then
    source "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme"
  else
    source "$ZSH/themes/$ZSH_THEME.zsh-theme"
  fi
fi
