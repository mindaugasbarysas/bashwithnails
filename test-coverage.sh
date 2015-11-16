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

command=$1
test_script=$2
if [[ $test_script == "" ]]
then
    test_script='tests.sh'
fi

case $1 in
    'verbose') testing::coverage_verbose $test_script "$IGNORE_COVERAGE";;
    'summary') testing::coverage_summary_exact $test_script "$IGNORE_COVERAGE";;
    'summary-fast') testing::coverage_summary_fast $test_script "$IGNORE_COVERAGE";;
    *) cat <<limitmark
    Usage: ./test-coverage.sh verbose|summary|summary-fast [test-script]

    verbose: print files executed by tests, color-coding the covered lines.
    summary: print exact summary of coverage.
    summary-fast: way faster summary, but possibly not as exact.

    test-script: bashwithnails test script. Defaults to "tests.sh"

    Getting >100% coverage? Check your annotations.
limitmark
    ;;
esac
