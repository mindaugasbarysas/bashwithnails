#!/bin/bash

DIR=`dirname "${BASH_SOURCE[0]}"`

if [[ -f $DIR/bootstrap.sh ]]
then
    . $DIR/bootstrap.sh
else
    echo "bootstrap not found"
    exit 256
fi

IGNORE_COVERAGE="tests/"

bootstrap_load_module "core/testing/coverage"

case $1 in
    'verbose') testing::coverage_verbose "tests.sh" "tests/";;
    'summary') testing::coverage_summary "tests.sh" "tests/";;
    *) echo "Usage: ./test-coverage.sh verbose|summary";;
esac
