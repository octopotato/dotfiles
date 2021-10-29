if command -v rbenv &>/dev/null; then
  eval "$(rbenv init -)"
fi

# Case-insensitive globbing (used in pathname expansion)
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function timer_now {
    date +%s%N
}

function timer_start {
    timer_start=${timer_start:-$(timer_now)}
}

function timer_stop {
    local delta_us=$((($(timer_now) - $timer_start) / 1000))
    local us=$((delta_us % 1000))
    local ms=$(((delta_us / 1000) % 1000))
    local s=$(((delta_us / 1000000) % 60))
    local m=$(((delta_us / 60000000) % 60))
    local h=$((delta_us / 3600000000))
    # Goal: always show around 3 digits of accuracy
    if ((h > 0)); then timer_show=${h}h${m}m
    elif ((m > 0)); then timer_show=${m}m${s}s
    elif ((s >= 10)); then timer_show=${s}.$((ms / 100))s
    elif ((s > 0)); then timer_show=${s}.$(printf %03d $ms)s
    elif ((ms >= 100)); then timer_show=${ms}ms
    elif ((ms > 0)); then timer_show=${ms}.$((us / 100))ms
    else timer_show=${us}us
    fi
    unset timer_start
}

# Add the ellapsed time and current date
#timer_stop

#\t= time, \u = user, \w = working directory, \[\e[0m\] = no color
#export PS1="\t|\u:\w\[\033[01;32m\]\$(parse_git_branch)\[\e[0m\] took ($timer_show)$ "
export PS1="\t|\u:\w\[\033[01;32m\]\$(parse_git_branch)\[\e[0m\]$ "

# Create as alias for nuget
alias nuget="mono /usr/local/bin/nuget.exe"

# Create alias for ll
alias ll='ls -lG'

# docker
function dk() {
    cmd=$1
    shift
    docker $cmd $@
}

alias dkps="dk ps"

## Git
alias gs='git status'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gcl='git clone'
alias gco='git checkout'
__git_complete gco _git_checkout
alias gm='git merge'
__git_complete gm _git_merge
alias gms='git merge --squash'
__git_complete gms _git_merge
alias gr='git rebase'
__git_complete gr _git_rebase
alias gpul='git pull --rebase'
alias gpush='git push -u'
alias gprune='git fetch --prune origin && git remote prune origin && git prune && git gc'
alias gdtags='git tag | xargs -n 1 git tag -d'
function gd() {
    if ! git branch -d $1; then
        gdf $1
    fi
    #git push origin :$1
}
__git_complete gd _git_branch

function gdf() {
    branch=$1
    read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        git branch -D $branch
    fi
}
__git_complete gdf _git_branch

function ccd() {
    local default_repo="$HOME/enlistment/appcenter"
    local rootdir=$(git rev-parse --show-toplevel 2> /dev/null || echo "$default_repo")
    cd "$rootdir"
}

function cssql() {
  docker run --rm -it mcr.microsoft.com/mssql-tools /opt/mssql-tools/bin/sqlcmd -U sa -P Your^StrongP3ssw0rd -S 172.17.0.1,8000 $*
}

#**************************
#Usage: abuild base (to build diagnostics base image)
#**************************
if [ -d $HOME/enlistment/appcenter/dockercompose ]; then
  for filename in $HOME/enlistment/appcenter/dockercompose/*.ps1
  do
    cmd=$(basename $filename .ps1)

    eval "a${cmd}() { echo "$HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 diagnostics/docker \$@" && $HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 diagnostics/docker \$@; }"
    eval "c${cmd}() { echo "$HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 crashes-docker \$@" && $HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 crashes-docker \$@; }"
    eval "cs${cmd}() { echo "$HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 core-services/docker \$@" && $HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 core-services/docker \$@; }"
    eval "d${cmd}() { echo "$HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 distribution/docker \$@" && $HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 distribution/docker \$@; }"
    eval "ci${cmd}() { echo "$HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 build/docker \$@" && $HOME/enlistment/appcenter/dockercompose/${cmd}.ps1 build/docker \$@; }"
  done
fi

function dchelp() {
    echo "a = diagnostics, c = crashes, cs = core-services, d = distribution, ci = build"
}

#export SSH_AUTH_SOCK=/tmp/.ssh-socket-$(uname)
#ssh-add -l 2>&1 >/dev/null
#if [ $? = 2 ]; then
#    rm -f /tmp/.ssh-script-$(uname) /tmp/.ssh-agent-pid-$(uname) /tmp/.ssh-socket-$(uname)
#    ssh-agent -a $SSH_AUTH_SOCK > /tmp/.ssh-script-$(uname)
#    . /tmp/.ssh-script-$(uname)
#    echo $SSH_AGENT_PID > /tmp/.ssh-agent-pid-$(uname)
#    ssh-add;  # You may have to enter path to private key if not automatically found like ssh-add .ssh/id_rsa
#fi

#function setupchef() {
#    scp -P 50001 $*-backend.cloudapp.net:/etc/chef-server/admin.pem $*-backend.cloudapp.net:/etc/chef-server/chef-validator.pem /c/chef/
#    knife ssl fetch -c /c/chef/client.rb
#    knife node list -c /c/chef/client.rb
#}
#
## Platform access via operation tunnel
#
#function pssh() {
#  domain=$1
#  prefix=$2
#  shift 2
#  if [ -z "$1" ]; then
#   ssh_string=""
#  else
#   ssh_string="ssh $prefix$*"
#  fi
#  ssh -t operation.$domain.capptain.com $ssh_string
#}
#
#function prod() {
#  pssh prod aws $*
#}
#
#function eu01() {
#  pssh eu01 azu $*
#}
#
#function eu02() {
#  pssh eu02 aws $*
#}
#
#function dev() {
#  prefix="aws"
#  shift 2
#  if [ -z "$1" ]; then
#   ssh_string=""
#  else
#   ssh_string="ssh $prefix$*"
#  fi
#  ssh -t operation.dev.ubithere.com $ssh_string
#}
#
#function su() {
#    ssh $*-backend.cloudapp.net
#    #ssh ubuntubuild.cloudapp.net
#    #ssh devdm2004-backend.cloudapp.net
#    #ssh devdb4001-backend.cloudapp.net
#}
#function azuredm() {
#    ssh proddm2001-backend.cloudapp.net
#}
#function azuredb() {
#    ssh proddb4001-backend.cloudapp.net
#}

#trap 'timer_start' DEBUG
