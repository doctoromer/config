CURRENT_DIR=$(dirname $(realpath $0))

source $CURRENT_DIR/plugins.zsh
source $CURRENT_DIR/alias.zsh
source $CURRENT_DIR/theme.zsh

bindkey "${terminfo[kRIT5]}" forward-word
bindkey "${terminfo[kLFT5]}" backward-word

# History options
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY

# Highlight on select
zstyle ':completion:*' menu select

# Allow shift-tab completion
zmodload zsh/complist
bindkey -M menuselect "${terminfo[kcbt]}" reverse-menu-complete

# Smarter completion
zstyle ':completion:*' matcher-list '' '+m:{a-zA-Z}={A-Za-z}' '+r:|[.,_-]=* r:|=*' '+l:|=* r:|=*'

# Fzf
export FZF_DEFAULT_COMMAND='ag -l --nocolor --nogroup --hidden -g "" --ignore ".git"'
source /usr/local/share/zsh/site-functions/fzf-completion.zsh
source /usr/local/share/zsh/site-functions/fzf-key-bindings.zsh
