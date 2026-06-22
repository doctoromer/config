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

zmodload zsh/terminfo

history_keymaps=(emacs viins vicmd)
history_up_keys=("${terminfo[kcuu1]}" "^[[A" "^[OA")
history_down_keys=("${terminfo[kcud1]}" "^[[B" "^[OB")

for keymap in $history_keymaps; do
    bindkey -M "$keymap" >/dev/null 2>&1 || continue
    for key in $history_up_keys; do
        [[ -n "$key" ]] && bindkey -M "$keymap" "$key" history-substring-search-up
    done
    for key in $history_down_keys; do
        [[ -n "$key" ]] && bindkey -M "$keymap" "$key" history-substring-search-down
    done
done

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
