#!/bin/bash

DIR=`dirname "${BASH_SOURCE[1]}"`
SCRIPT_DIR=$DIR
GLOBAL_REPOSITORY_ADDRESS="https://raw.githubusercontent.com/mindaugasbarysas/bashwithnails/master/sample_repo/repofile"
GLOBAL_CACHE_DIR="$DIR/cache"
MODULE_DIR="modules"
if [[ -f /sbin/md5 ]]
then
    MD5='/sbin/md5'
else
    MD5='/usr/bin/md5sum'
fi
# ERROR DEFINITIONS

ERROR_NOT_FOUND=101
ERROR_BAD_PROGRAMMER=1
ERROR_BAD_USER=2
