#!/bin/bash
#NAMESPACE=bootstrap

function bootstrap::load_environment
{
     DIR=`dirname "${BASH_SOURCE[0]}"`
     if [[ -f $DIR/vars/environment.sh ]]
     then
        . $DIR/vars/./environment.sh
     fi
}

function bootstrap::load_module()
{
    if [[ $SCRIPT_DIR == '' ]]
    then
        bootstrap::load_environment
    fi
    if [[ ! -f $SCRIPT_DIR/$MODULE_DIR/$1 ]]
    then
        return $ERROR_NOT_FOUND
    fi
    local NAMESPACE=`cat $SCRIPT_DIR/$MODULE_DIR/$1 | grep "NAMESPACE=" | cut -d= -f2`

    if [[ $NAMESPACE == "" ]]
    then
        echo "Warning: no namespace set in $1, assuming NAMESPACE=global"
        NAMESPACE="global"
    fi
    local TEMPFILE=`mktemp /tmp/shbs:${NAMESPACE}-${1//\//\~}.XXXXXXXXXX`
    bootstrap::check $1
    bootstrap::prepare_module $NAMESPACE $1 > $TEMPFILE
    . $TEMPFILE
    bootstrap::check $1
    rm $TEMPFILE
    bootstrap::check $1
}

function bootstrap::prepare_module()
{
    local NAMESPACE=$1
    local NAMESPACE_VAR=${NAMESPACE//::/__}
    local MODULE=$2
    cat $SCRIPT_DIR/$MODULE_DIR/$MODULE | \
    sed -e "s/function\ /function $NAMESPACE::/g" | \
    sed -e "s/namespaced /${NAMESPACE_VAR}__/g" | \
    sed -e "s/function \(.*\)(\(.*\)) {/function \1 { for varname in \2; do if [[ \$# -ne 0 ]]; then local \${varname}=\"\$1\"; shift; else echo \"Required function parameter '\$varname' not set when calling '\1'\"; fi; done;/g" | \
    sed -e "s/this::/$NAMESPACE::/g";
}

function bootstrap::module_from_namespace()
{
    grep -Re "#NAMESPACE=${1}$" $SCRIPT_DIR/$MODULE_DIR/* | cut -d: -f 1 | sed -e "s/\(.*\)$MODULE_DIR\///g"
}

function bootstrap::load_namespace()
{
    for module in `grep -Re "NAMESPACE=${1}$" $SCRIPT_DIR/$MODULE_DIR/* | cut -d: -f 1 | sed -e "s/$SCRIPT_DIR\/$MODULE_DIR\//g"`
    do
        bootstrap::load_module $module
    done
}

function bootstrap::check()
{
    if [[ $? -ne 0 ]]
    then
        echo "Error loading module $1"
        bootstrap::trace
        exit 1
    fi
}

function bootstrap::trace
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

function bootstrap::check_fn_parameters()
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

bootstrap::load_module core/dependencies
