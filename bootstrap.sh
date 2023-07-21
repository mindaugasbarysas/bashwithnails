#!/bin/bash

____BOOTSTRAP_MODULES=()

function bootstrap_sane_global_defaults
{
    if [[ -z $DIR ]]
    then
        DIR=`dirname "${BASH_SOURCE[0]}"`
    fi

    if [[ -z $DIR ]]
    then
        SCRIPT_DIR=$DIR
    fi

    if [[ -z $MODULE_DIR ]]
    then
        MODULE_DIR="modules"
    fi

    if [[ -z $LOCAL_MODULE_DIR ]]
    then
        LOCAL_MODULE_DIR="app"
    fi
}

function bootstrap_load_environment
{
     DIR=`dirname "${BASH_SOURCE[0]}"`
     if [[ -f $DIR/vars/environment.sh ]]
     then
        . $DIR/vars/./environment.sh
     fi
}

function bootstrap_load_module()
{
    local MOD
    local MDIR
    local LOAD_FLAG=0
    for MOD in ${____BOOTSTRAP_MODULES[@]}
    do
        if [[ $MOD == $1 ]]
        then
            return 0
        fi
    done

    if [[ $SCRIPT_DIR == '' ]]
    then
        bootstrap_load_environment
    fi

    for MDIR in $MODULE_DIR $LOCAL_MODULE_DIR
    do
        if [[ ! -f $SCRIPT_DIR/$MDIR/$1 ]]
        then
            continue
        fi
        local NAMESPACE=`cat $SCRIPT_DIR/$MDIR/$1 | grep "NAMESPACE=" | cut -d= -f2`


        if [[ $NAMESPACE == "" ]]
        then
            echo "Warning: no namespace set in $1, assuming NAMESPACE=global"
            NAMESPACE="global"
        fi
        local COMPFILE="/tmp/shbs:${NAMESPACE}-${1//\//\~}.cached"
        if [[ -f $SCRIPT_DIR/$MDIR/$1 && -f $COMPFILE && "`date +%s -r $SCRIPT_DIR/$MDIR/$1`" -le "`date +%s -r $COMPFILE`" ]]; then
            . $COMPFILE
            ____BOOTSTRAP_MODULES+=($1)
            return
        fi

        bootstrap_check $1
        bootstrap_prepare_module $NAMESPACE $1 $MDIR > $COMPFILE
        . $COMPFILE
        bootstrap_check $1
        LOAD_FLAG=1
    done

    if [[ $LOAD_FLAG -gt 0 ]]; then
        ____BOOTSTRAP_MODULES+=($1)
        return 0
    fi

    return $ERROR_NOT_FOUND
}

function bootstrap_prepare_module()
{
    local NAMESPACE=$1
    local NAMESPACE_VAR=${NAMESPACE//::/__}
    local MODULE=$2
    local MDIR=$3
    cat $SCRIPT_DIR/$MDIR/$MODULE | \
    sed -e "s/function\ /function $NAMESPACE::/g" | \
    sed -e "s/namespaced /${NAMESPACE_VAR}__/g" | \
    sed -e "s/function \(.*\)(\(.*\)) {/function \1 { for varname in \2; do if [[ \$# -ne 0 ]]; then local \${varname}=\"\$1\"; shift; else echo \"Required function parameter '\$varname' not set when calling '\1'\"; bootstrap_trace; fi; done; if [[ \$# -ne 0 ]]; then echo \"Extra parameters given when calling '\1'\"; bootstrap_trace; fi;/g" | \
    sed -e "s/this::/$NAMESPACE::/g";
}

function bootstrap_module_from_namespace()
{
    local MDIR
    for MDIR in $LOCAL_MODULE_DIR $MODULE_DIR
    do
        grep -Re "#NAMESPACE=${1}$" $SCRIPT_DIR/$MDIR/ | cut -d: -f 1 | sed -e "s/\(.*\)$MDIR\///g" 2>&1
    done
}

function bootstrap_load_namespace()
{
    local MDIR
    for MDIR in $LOCAL_MODULE_DIR $MODULE_DIR
    do
        for module in `grep -Re "NAMESPACE=${1}$" $SCRIPT_DIR/$MDIR/ | cut -d: -f 1 | sed -e "s/$SCRIPT_DIR\/$MDIR\//g"`
        do
            MDIR=`echo $MDIR | rev`
            bootstrap_load_module $module
        done
    done
}

function bootstrap_check()
{
    if [[ $? -ne 0 ]]
    then
        echo "Error loading module $1"
        bootstrap_trace
        exit 1
    fi
}

function bootstrap_trace
{
    echo "At:"
    for key in ${!BASH_LINENO[@]}
    do
        if [[ $key -gt 0 ]]
        then
            echo -e "${key} \t ${BASH_SOURCE[$key]} -> ${FUNCNAME[$key]}():${BASH_LINENO[$key - 1]}"
        fi
    done
}

function bootstrap_check_fn_parameters()
{
    local function_name=$1
    local parameters=$2
    reflected_function=`type $function_name 2>&1`
    if [[ `echo "$reflected_function" | grep -c 'is a function'` -eq 1 ]]
    then
        if [[ `echo "$reflected_function" | grep -c 'in '"${parameters[@]}"` -eq 1 ]]
        then
            return 0;
        else
            echo "$function_name() does not have parameters (${parameters[@]}) or they are in wrong order!"
        fi
    else
        echo "$function_name is not a function!"
    fi
    return $ERROR_BAD_PROGRAMMER
}

bootstrap_sane_global_defaults

bootstrap_load_module core/dependencies
