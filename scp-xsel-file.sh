#!/bin/bash

SERVER="strawberry"
BMAP=false

function RUN() {
    ${RUNNER} "$@"
}

function usage_exit() {
    echo "Usage: $0 [-nh] imagename"
    echo "       -b(--bmap)   : download with bmap"
    echo "       -n(--dry-run): dry run"
    echo "       -h(--help)   : help(this message)"
    exit 0
}


function check_args() {
    declare args
    args=$(getopt -o bnh -l bmap,dry-run,help -- "$@") || exit 22
    eval set -- "$args"

    # loop for parsing
    while [ $# -gt 0 ]; do
        case $1 in
	    -b | --bmap)
		BMAP=true
		shift
		;;
            -n | --dry-run)
                RUNNER="echo"
                shift
                ;;
            -h | --help)
                usage_exit
                shift
                ;;
            --)
                shift
                break
                ;;
        esac
    done
}

function download() {
    declare image_path
    declare bmap_path
    image_path=$(xsel -o)
    bmap_path="${image_path%.*}.bmap"

    RUN scp "${SERVER}:${image_path}" ./

    if ${BMAP}; then
	RUN scp "${SERVER}:${bmap_path}" ./
	if [ $? -ne 0 ]; then
	    RUN scp "${SERVER}:${image_path}.bmap" ./
	fi
    fi
}


check_args "$@"
download
