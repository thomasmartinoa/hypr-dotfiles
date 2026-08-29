# Created by newuser for 5.9
 
eval "$(starship init zsh)"

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

alias ls="eza"
alias ll="eza -l"
alias c="clear"
alias ff="fastfetch"
alias q="exit"

export PATH="$HOME/.local/bin:$PATH"
