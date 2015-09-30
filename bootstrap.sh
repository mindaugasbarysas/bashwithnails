#!/bin/bash

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
    if [[ $SCRIPT_DIR == '' ]]
    then
        bootstrap_load_environment
    fi
    if [[ ! -f $SCRIPT_DIR/modules/$1 ]]
    then
        return $ERROR_NOT_FOUND
    fi
    local NAMESPACE=`cat $SCRIPT_DIR/modules/$1 | grep "NAMESPACE=" | cut -d= -f2`

    if [[ $NAMESPACE == "" ]]
    then
        echo "Warning: no namespace set in $1, assuming NAMESPACE=global"
        NAMESPACE="global"
    fi

    local TEMPFILE=`mktemp /tmp/sh-bootstrap-${NAMESPACE}.XXXXXXXXXX`
    bootstrap_check $1
    bootstrap_prepare_module $NAMESPACE $1 > $TEMPFILE
    . $TEMPFILE
    bootstrap_check $1
    rm $TEMPFILE
    bootstrap_check $1
}

function bootstrap_prepare_module()
{
    local NAMESPACE=$1
    local NAMESPACE_VAR=${NAMESPACE//::/__}
    local MODULE=$2
    cat $SCRIPT_DIR/modules/$MODULE | \
    sed -e "s/function\ /function $NAMESPACE::/g" | \
    sed -e "s/namespaced /${NAMESPACE_VAR}__/g" | \
    sed -e "s/function \(.*\)(\(.*\)) {/function \1 { for varname in \2; do if [[ \$# -ne 0 ]]; then local \${varname}=\"\$1\"; shift; else echo \"Required function parameter '\$varname' not set when calling '\1'\"; fi; done;/g" | \
    sed -e "s/this::/$NAMESPACE::/g";
}

function bootstrap_module_from_namespace()
{
    grep -Re "#NAMESPACE=${1}$" $SCRIPT_DIR/modules/* | cut -d: -f 1 | sed -e "s/\(.*\)modules\///g"
}

function bootstrap_load_namespace()
{
    for module in `grep -Re "NAMESPACE=${1}$" $SCRIPT_DIR/modules/* | cut -d: -f 1 | sed -e "s/$SCRIPT_DIR\/modules\//g"`
    do
        bootstrap_load_module $module
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

bootstrap_load_module core/dependencies
