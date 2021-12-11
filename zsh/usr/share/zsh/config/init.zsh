CURRENT_DIR=$(dirname $(realpath $0))

source $CURRENT_DIR/plugins.zsh
source $CURRENT_DIR/alias.zsh
source $CURRENT_DIR/theme.zsh

export EDITOR="vim"

# History options
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY

# Fzf
export FZF_DEFAULT_COMMAND='ag -l --nocolor --nogroup --hidden -g "" --ignore ".git"'
source /usr/local/share/zsh/site-functions/fzf-completion.zsh
source /usr/local/share/zsh/site-functions/fzf-key-bindings.zsh
