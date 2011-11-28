#!/bin/bash

OS=$(uname -a|awk '{print $1}')
# Expected values Linux, Darwin
echo "os is $OS"

case $OS in
    Linux) READLINK="readlink" ;;
    Darwin) READLINK="greadlink" ;;
    *) echo "Unable to handle OS $OS, exiting" >&2;
        exit 1;
    ;;
esac

SCRIPT_DIRECTORY=$(cd $(dirname $(${READLINK} -f $0)) && pwd)
command=$1;

function usage() {
cat <<EOF
usage: git update operation

Operation can be one of the following:
    get: Get updates from the master branch
    push: Push updates from the master branch (requires tig)
EOF
}

function run() {
    echo;
    echo $@;
    eval $@;
}

run git diff --exit-code >/dev/null
if [ $? -ne 0 ]; then
    echo "Error: git diff reports non-clean directory";
    exit 1;
fi

source $SCRIPT_DIRECTORY/functions.sh

get-local-branch
localBranch=$branch

case "$command" in
    push) echo "Going to push";
        push-update $localBranch;
        ;;
    get) echo "Going to update";
        get-update $localBranch;
        ;;
    *) echo "Didn't understand command \"$command\"";
        usage;
        ;;
esac
