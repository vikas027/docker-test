## History Tweaks
shopt -s histappend
PROMPT_COMMAND='history -n; history -a'
export HISTTIMEFORMAT="%d/%m/%y %T "
export HISTSIZE=10000
export HISTFILESIZE=10000

## Bash Prompt Color -- red for root && green for non-root users
if [ $UID -eq 0 ]
then
  export PS1="\[\e[31m\]\u@\h:\w#\[\e[m\] "
else
  export PS1="\[\e[32m\]\u@\h:\w\$\[\e[m\] "
fi

## MISC
alias vi='vim'
