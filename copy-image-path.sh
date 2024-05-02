#!/bin/bash

RUNNER=""
IMAGE=""
BUILD_DIR=""
FTYPE="l"
MACHINE=""

function RUN() {
    ${RUNNER} "$@"
}

function usage_exit() {
    echo "Usage: $0  [-b build-dir] [-m machine] [-nh] imagename"
    echo "       -b(--build-dir): build direcotry"
    echo "       -m(--machine)  : machine name"
    echo "       -i(--isar)     : for isar"
    echo "       -n(--dry-run)  : dry run"
    echo "       -h(--help)     : help(this message)"
    exit 0
}


function check_args() {
    declare args
    args=$(getopt -o b:m:inh -l build-dir:,machine:,isar,dry-run,help -- "$@") || exit 22
    eval set -- "$args"

    # loop for parsing
    while [ $# -gt 0 ]; do
        case $1 in
	    -b | --build-dir)
		BUILD_DIR="$2"
		shift 2
		;;
	    -m | --machine)
		MACHINE="$2"
		shift 2
		;;
	    -i | --isar)
		FTYPE="f"
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

    IMAGE=$1
    if [ "${IMAGE}" = "" ]; then
        usage_exit
    fi

    echo "IMAGE     = ${IMAGE}"
    echo "BUILD_DIR = ${BUILD_DIR}"
}

function find_image_path() {
    declare -r target_dir="$1"
    declare found_path=""

    echo "target_dir = ${target_dir}"
    found_path=$(find "${target_dir}" -type ${FTYPE} -a -name "${IMAGE}*wic.*" -not -name '*.bmap'| head -n1)
    echo "found_path = ${found_path}"
    if [ -z "${found_path}" ]; then
	found_path=$(find "${target_dir}" -name "${IMAGE}*wic" | head -n1)
    fi
    if [ -z "${found_path}" ]; then
	echo "wic not found."
	return 1
    fi
    echo -n "${found_path}" | xsel
    echo "${found_path} is copied!"
    return 0
}

check_args "$@"
if ! find_image_path "${PWD}/${BUILD_DIR}/tmp/deploy/images/${MACHINE}"; then
    find_image_path "${PWD}/${BUILD_DIR}/tmp-glibc/deploy/images/${MACHINE}"
fi
