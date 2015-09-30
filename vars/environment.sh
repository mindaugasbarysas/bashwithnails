#!/bin/bash

DIR=`dirname "${BASH_SOURCE[1]}"`
SCRIPT_DIR=$DIR
GLOBAL_REPOSITORY_ADDRESS="https://raw.githubusercontent.com/mindaugasbarysas/bashwithnails/master/sample_repo/repofile"
GLOBAL_CACHE_DIR="$DIR/cache"


# ERROR DEFINITIONS

ERROR_NOT_FOUND=404
ERROR_BAD_PROGRAMMER=500
ERROR_BAD_USER=406
