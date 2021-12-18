#!/bin/bash

# source this file in the shell
#
# place in /etc/profile.d/zzz-tmux-agent-wrap.sh
#
# the shell function tmx will start a new, persistent (meaning you can be
# connected to it multiple times at the same time), with the ssh-agent
# connection available even if you get disconnected and reconnect
#
#  start or connect to an instance named "default"
#     tmx
#  list running instances
#     tmx ls
#  start or connect to an instance named "bone"
#     tmx bone
#
# It starts up multiple tmux servers, one for each name, rather than one
# server with multiple sessions in it.  This avoids the accidental killing
# of all sessions while in one of them.  tmux "sessions" are kind of
# convoluted (when using multiple attachments).

function tmx() {
    local PATH=/usr/bin:/bin:/usr/sbin
    local thename=${1:-default}

    if [ "$thename" = "ls" ]; then
            lsof -F n -u $EUID 2>/dev/null | grep tmux-$EUID | sed -e 's/ type=.*$//g;' | grep '^n' | xargs --no-run-if-empty -n 1 basename | sort | uniq
            return 0
    fi

    case $TERM in
        screen* )
            echo "Let's not try to run tmux inside tmux" >&2
            return 1
            ;;
    esac

    # if the auth socket variable is empty, don't do anything
    if [[ -n "$SSH_AUTH_SOCK" ]]; then
        local BDIR=/dev/shm/.sshtmux-${USER}-${EUID}
        if grep -qs '^tmpfs /dev/shm ' /proc/mounts; then
            if ! mkdir -m 0700 -p ${BDIR} 2>/dev/null ; then
                BDIR=$HOME
            else
                find $BDIR -xtype l -iname ".agent-sshtmux-${USER}*" -delete
            fi
        fi
        # include USER to protect against shared HOME directories (rare)
        local NEWSOCK="$BDIR/.agent-sshtmux-${USER}-${thename}.sock"
        if [[ "$SSH_AUTH_SOCK" != "$NEWSOCK" ]]; then
            # test if the auth sock we have is actually working
            # don't link to a dead socket
            if ssh-add -l > /dev/null 2>&1; then
                ln -sf "$SSH_AUTH_SOCK" "$NEWSOCK"
                SSH_AUTH_SOCK=$NEWSOCK _spawn_tmux "$@"
            else
                echo "tmx: agent appears to have no keys (agent locked?)" >&2
            fi
        else
            echo "tmx: SSH_AUTH_SOCK already redirected, odd state" >&2
        fi
    else
        echo "tmx: SSH_AUTH_SOCK is not set" >&2
    fi
}

function _spawn_tmux() {
    local TMUX=/usr/bin/tmux
    local thename=${1:-default}

    if ! $TMUX -L "$thename" has-session -t "default" 2>/dev/null ; then
        # server not running, start it
        # create a new detached session, set an option on it
        $TMUX -L "$thename" -2 \
            new-session -d -s "default" \; \
            set -t "default" destroy-unattached off \;
    fi
    mytty=$( /usr/bin/tty )
    sessioninstance="${mytty#/*/} $thename"
    $TMUX -L "$thename" -2 new-session -A -s "$sessioninstance" -t "default"
}

