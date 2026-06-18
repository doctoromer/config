CURRENT_DIR=$(dirname $(realpath $0))

zstyle ':zcomet:*' repos-dir $CURRENT_DIR/repos
zstyle ':zcomet:*' snippets-dir $CURRENT_DIR/snippets

source $CURRENT_DIR/zcomet/zcomet.zsh

DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=blue,bold,underline"

zcomet load hlissner/zsh-autopair
zcomet load zsh-users/zsh-autosuggestions
zcomet load zsh-users/zsh-syntax-highlighting
zcomet load MichaelAquilina/zsh-you-should-use
zcomet load zsh-users/zsh-history-substring-search

export HISTORY_SUBSTRING_SEARCH_PREFIXED=true

# $terminfo doesn't work for some reason for up and down keys
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

if [[ "$CONFIG_ZSH_VI_MODE" = true ]]; then
    export EDITOR="vim"

    # To prevent zsh-vi-mode from overriding other keybindings (like fzf's ctrl-r)
    function zvm_config() {
        ZVM_INIT_MODE=sourcing
        ZVM_VI_SURROUND_BINDKEY=classic
        ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    }

    zcomet load jeffreytse/zsh-vi-mode
fi

bindkey "^ " autosuggest-accept
