# aliases for system maintenance
alias depend='sudo apt -f install'
alias update='sudo apt update'
alias upgrade='sudo apt -y upgrade'
alias clean='sudo apt -y autoclean'
alias autorm='sudo apt -y autoremove'
alias maintain='update && depend && upgrade && clean && autorm'

alias cat=bat
alias ls=exa
alias la='exa -a'
alias l='exa -F'
alias tree="exa -T --color=always"

if [ -f /.dockerenv ]; then
    alias vim="nvim --appimage-extract-and-run"
    alias tmux="tmux --appimage-extract-and-run -u2"
else
    alias vim=nvim
    alias tmux="tmux -u2"
fi

better_ll() {
    exa -l --color=always $* | less -RFX
}
alias ll=better_ll

most() {
    case "$1" in
        mem)
            ;;
        cpu)
            ;;
        *)
            echo "Valid parameters: mem, cpu."
            return
    esac
    ps -eo pid,cmd,%mem,%cpu --sort=-%$1 | head
}

iface() {
    ip a | grep -o "^[0-9]: [a-zA-Z0-9]*" | cut -d' ' -f2
}

netrst() {
    case "$#" in
        0)
            sudo dhclient -r -v; sudo dhclient -v
            ;;
        *)
            for interface in "$@"; do
                sudo dhclient -r -v $interface && sudo dhclient -v $interface
            done
            ;;
    esac
}

alias dirsize="du -s -h"
alias sudo='sudo '

# aliases for paging ag output with colors
alias less='less -r'
alias ag='ag --color --group'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'
