# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# secret key environment variables for rails (PARLO Tracker)
SECRET_KEY_BASE=xxxxxx
export SECRET_KEY_BASE

US_STAGE_SECRET_KEY_BASE=yyyyyyy
export US_STAGE_SECRET_KEY_BASE

EG_STAGE_SECRET_KEY_BASE=zzzzzzz
export EG_STAGE_SECRET_KEY_BASE

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# PATH=/usr/lib64/qt5/bin:/home/deploy/.rvm/gems/ruby-2.4.1/bin:/home/deploy/.rvm/gems/ruby-2.4.1@global/bin:/home/deploy/.rvm/rubies/ruby-2.4.1/bin:/home/deploy/.rvm/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/dtaylor/.local/bin:/home/dtaylor/bin
# PATH=/usr/lib64/qt5/bin:/home/deploy/.rvm/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/dtaylor/.local/bin:/home/dtaylor/bin

# rvm get stable --auto-dotfiles
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
