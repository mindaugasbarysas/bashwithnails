#!/bin/bash

DIR=`dirname "${BASH_SOURCE[0]}"`
if [[ -f $DIR/bootstrap.sh ]]
then
    . $DIR/bootstrap.sh
else
    echo "bootstrap not found"
    exit 256
fi

bootstrap::load_module routing/iproute

interfaces=('eth1' 'eth2')
gateways=('192.168.8.1' '192.168.7.1')
weigths=(2 1)

routing::iproute::setup_gateways_simple $interfaces $gateways $weigths

# run.
