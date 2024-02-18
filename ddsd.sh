#!/bin/bash -e
##
# dd to removable media script
# This script resolve removable device name automatically.
#

RUNNER=""
SDCARD=$(cd /sys/block && grep ^ -- */removable | grep :1 | cut -d'/' -f1 | grep sd | tr '\n' ' ')
DRYRUN=0
BMAP_OPT=""
BLOCK_SIZE=100M

function RUN() {
    ${RUNNER} "$@"
}

function fixup_multi_devices() {
    declare -r drv="${SDCARD}"
    for d in ${drv}; do
        SDCARD="${d}"
        break
    done
}

function check_dev() {
    if [ "${SDCARD}" = "" ]; then
        echo "removable device is not found."
        exit
    fi
    if [ ! -e "/dev/${SDCARD}" ]; then
        echo "a removable media is not ready."
        exit
    fi
    echo "ok ${SDCARD} is available."
}

function prepare_device() {
    declare mount_point=(/media/"${USER}"/*)

    check_dev
    set +e
    RUN sudo umount "${mount_point[@]}"
    set -e
}

function usage_exit() {
    echo "Usage: $0 [-nbBh] [-s block-size] imagefile"
    echo "       -n(--dry-run): dry run"
    echo "       -b(--bmap)   : use bmaptool"
    echo "       -B(--no-bmap): use bmaptoth without bmap file"
    echo "       -h(--help)   : help(this message)"
    exit 0
}

function check_args() {
    declare args
    args=$(getopt -o s:nbBh -l size:,dry-run,bmap,no-bmap,help -- "$@") || exit 22
    eval set -- "$args"

    # loop for parsing
    while [ $# -gt 0 ]; do
        case $1 in
            -s | --size)
                BLOCK_SIZE=${2}
                shift 2
                ;;
            -n | --dry-run)
                RUNNER="echo"
                shift
                ;;
            -b | --bmap)
                BMAP=1
                shift
                ;;
            -B | --no-bmap)
                BMAP=1
                BMAP_OPT="--nobmap"
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

    IMAGEFILE=$1
    if [ "${IMAGEFILE}" = "" ]; then
        usage_exit
    fi
}

check_args "$@"
fixup_multi_devices

echo "image file       = ${IMAGEFILE}"
echo "removable device = ${SDCARD}"
echo "block size       = ${BLOCK_SIZE}"
echo "use bmaptool     = ${BMAP}"
echo "dry run          = ${DRYRUN}"

prepare_device
if [ "${BMAP}" = "1" ]; then
    RUN sudo bmaptool copy ${BMAP_OPT} "${IMAGEFILE}" /dev/"${SDCARD}"
else
    RUN sudo dd if="${IMAGEFILE}" of=/dev/"${SDCARD}" bs="${BLOCK_SIZE}"
fi
RUN sudo eject /dev/"${SDCARD}"
echo "done."
