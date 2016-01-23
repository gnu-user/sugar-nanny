# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Set VIM as the defaul editor
export VISUAL=vim
export EDITOR=vim

# Python virtual environments
export WORKON_HOME=$HOME/.virtualenv
source /usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/activate.sh

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILE=~/.bash_history
HISTSIZE=100000
HISTFILESIZE=250000

# Don't let the users enter commands that are ignored
# in the history file
HISTIGNORE=""
readonly HISTFILE
readonly HISTSIZE
readonly HISTFILESIZE
readonly HISTIGNORE
readonly HISTCONTROL
export HISTFILE HISTSIZE HISTFILESIZE HISTIGNORE HISTCONTROL

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias lt='ls -laht'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# emacs aliases
alias emacs-standalone=emacs
alias emacs="emacsclient -t"
alias e="emacsclient -t"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Make less search case insensitive
alias less='less -i'


#colourized man pages
man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

# CD shorcuts
alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."

### Shortcut for wget with user agent ###
alias download='wget -nc --progress=bar -U "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 (.NET CLR 3.5.30729)"'

alias continue-download='wget --continue --progress=bar -U "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 (.NET CLR 3.5.30729)"'

### Copies files with progress
cp_p() {
   strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
      | awk '{
        count += $NF
            if (count % 10 == 0) {
               percent = count / total_size * 100
               printf "%3d%% [", percent
               for (i=0;i<=percent;i++)
                  printf "="
               printf ">"
               for (i=percent;i<100;i++)
                  printf " "
               printf "]\r"
            }
         }
         END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

### Handy alias for rsync options I usually always want and to auto-retry if 
### rsync fails while copying the file 
jsync()
{
    while :
    do 
        rsync -ahz -vv -P "${1}" "${2}"

        if [[ $? -eq 0 ]]
        then
            break
        fi

        sleep 5
    done
}

### Compression function, uses a fast parallel version of gzip with progress bar
compress()
{
    files=("$@")

    for file in "${files[@]}"
    do
        SIZE=`du -sk "${file}" | cut -f 1`
        tar cvf - "${file}" | pv -p -s ${SIZE}k | pigz -c > ${file%.*}.tar.gz
    done
}

### Compress function for directory, compresses the entire directory and its 
### contents as one file using parallel version of gzip with progress
compress_dir()
{
    dir="${1%/}"
    tar cvf - "${dir}" | pv -p -s $(du -sk "${dir}" | awk '{print $1}')k | pigz > ${dir}.tar.gz
}

# Display all files a user has contributed to
gituserfiles()
{
    git log --pretty="%H" --author="${1}" |
        while read commit_hash
        do
            git show --oneline --name-only $commit_hash | tail -n+2
        done | sort | uniq
}

# Only add a certain file or file based on pattern that is modified
gitaddfile()
{
    find . -name "${1}" -exec git add -u {} \;
}

# Ignore changes made to a local file, even if tracked
# useful for ignoring passwords set in authorization file
gitignorefile()
{
    git update-index --assume-unchanged  "${1}"
}

# copy all the template files as the new <name>_<#> specified
renameall()
{
    # Copy files as a new name
    find . -type f -name "${1}*" | grep -Po '(\.\w+)' | xargs -L1 -I {} cp "${1}"{} "../${1}/${1}_${2}"{}
}
