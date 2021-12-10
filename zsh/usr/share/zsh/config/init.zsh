CURRENT_DIR=$(dirname $(realpath $0))

zstyle ':zcomet:*' repos-dir $CURRENT_DIR/repos
zstyle ':zcomet:*' snippets-dir $CURRENT_DIR/snippets

source $CURRENT_DIR/zcomet/zcomet.zsh
source $CURRENT_DIR/plugins.zsh
source $CURRENT_DIR/alias.zsh
source $CURRENT_DIR/theme.zsh

export EDITOR="vim"

# Fzf
export FZF_DEFAULT_COMMAND='ag -l --nocolor --nogroup --hidden -g "" --ignore ".git"'
source /usr/local/share/zsh/site-functions/fzf-completion.zsh
source /usr/local/share/zsh/site-functions/fzf-key-bindings.zsh
