DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=blue,bold,underline"

zcomet load ohmyzsh plugins/git
zcomet load ohmyzsh plugins/ag
zcomet load ohmyzsh plugins/git
zcomet load ohmyzsh plugins/vi-mode
zcomet load ohmyzsh plugins/colored-man-pages
zcomet load ohmyzsh plugins/command-not-found

zcomet load hlissner/zsh-autopair
zcomet load zsh-users/zsh-autosuggestions
zcomet load zsh-users/zsh-syntax-highlighting

bindkey "^ " autosuggest-accept
