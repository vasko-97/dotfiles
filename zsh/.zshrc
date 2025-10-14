# .zshrc
autoload -Uz compinit promptinit
compinit -C
promptinit
prompt off

# Ensure UTF-8 is used regardless of the terminal default
export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8

# START PROMPT DEFINITION
# Enable prompt substitution
setopt PROMPT_SUBST

# Define colors
BRACKET_COLOR='%F{35}'
CLOCK_COLOR='%F{35}'
JOB_COLOR='%F{33}'
PATH_COLOR='%F{33}'
LINE_COLOR='%F{248}'
RESET='%f'

# Define special characters
LINE_UPPER_CORNER='┌'
LINE_STRAIGHT='─'
LINE_BOTTOM_CORNER='└'
LINE_BOTTOM='─'
END_CHARACTER='|'

# Set prompt for interactive shells
if [[ -o interactive ]]; then
  PROMPT="${LINE_COLOR}${LINE_UPPER_CORNER}${LINE_STRAIGHT}${LINE_STRAIGHT}${BRACKET_COLOR}[${CLOCK_COLOR}%*${BRACKET_COLOR}]${LINE_COLOR}${LINE_STRAIGHT}${BRACKET_COLOR}[${JOB_COLOR}%j${BRACKET_COLOR}]${LINE_COLOR}${LINE_STRAIGHT}${BRACKET_COLOR}[%m:${PATH_COLOR}%~${BRACKET_COLOR}]${RESET}
${LINE_COLOR}${LINE_BOTTOM_CORNER}${LINE_STRAIGHT}${LINE_BOTTOM}${END_CHARACTER}${RESET} "
fi
# END PROMPT DEFINITION

# START HISTORY CONFIG
HISTFILE=~/.zsh_history
# conflate identical successive commands into one
setopt histignoredups
# multiple session will share the same history file
setopt sharehistory
# how many historic commands are stored in memory
HISTSIZE=1000
# how many historic commands are stored in the file
SAVEHIST=1000000
# ignores commands that start with a space, useful for sensitive commands
setopt histignorespace
# END HISTORY CONFIG

# enable vi mode
bindkey -v
export KEYTIMEOUT=1

bindkey -M viins '^P' up-line-or-history
bindkey -M vicmd '^P' up-line-or-history
bindkey -M viins '^N' down-line-or-history
bindkey -M vicmd '^N' down-line-or-history
# todo: instead look into ZLE's powerful widgets like history-incremental-pattern-search-backward, history-beginning-search-backward, or plugins like zsh-history-substring-search. See `zle -la`.
bindkey -M viins '^R' history-incremental-search-backward
# todo: instead look into more powerful zsh native methods like zsh-autosuggestions
# note \e might not be the right escape sequence for Alt on all terminals
bindkey -M viins '\e.' insert-last-word

# Change cursor shape for different vi modes: https://unix.stackexchange.com/a/614203
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# todo: migrate rest of bashrc
