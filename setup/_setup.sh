#!/bin/sh
set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PAGER=less
export PS1='\h:\w\$ '
umask 022

KERNEL_FLAVOR=$1
NBD_DEV=$2
SETUP_DIR=$PWD

USERNAME=alpine

_step_counter=0
step() {
    _step_counter=$(( _step_counter + 1 ))
    printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2
}

. $SETUP_DIR/setup-alpine.sh
#. $SETUP_DIR/setup-nodejs.sh

# Setup GUI Flavor
# . $SETUP_DIR/setup-graphic.sh
. $SETUP_DIR/setup-dwm.sh
. $SETUP_DIR/setup-autorun.sh

. $SETUP_DIR/setup-clean.sh

