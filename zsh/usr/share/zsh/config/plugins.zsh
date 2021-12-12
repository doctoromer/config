zstyle ':zcomet:*' repos-dir $CURRENT_DIR/repos
zstyle ':zcomet:*' snippets-dir $CURRENT_DIR/snippets

source $CURRENT_DIR/zcomet/zcomet.zsh

DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=blue,bold,underline"

# To prevent zsh-vi-mode from overriding other keybindings (like fzf's ctrl-r)
function zvm_config() {
    ZVM_INIT_MODE=sourcing
    ZVM_VI_SURROUND_BINDKEY=classic
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
}

zcomet load ohmyzsh plugins/git
zcomet load ohmyzsh plugins/ag
zcomet load ohmyzsh plugins/git
zcomet load ohmyzsh plugins/vi-mode
zcomet load ohmyzsh plugins/colored-man-pages
zcomet load ohmyzsh plugins/command-not-found

zcomet load hlissner/zsh-autopair
zcomet load zsh-users/zsh-autosuggestions
zcomet load zsh-users/zsh-syntax-highlighting
zcomet load Tarrasch/zsh-bd
zcomet load MichaelAquilina/zsh-you-should-use
zcomet load jeffreytse/zsh-vi-mode

bindkey "^ " autosuggest-accept
