#!/bin/sh
#
# SPDX-FileCopyrightText: 2024 Yusuke Mitsuki <mickey.happygolucky@gmail.com>
# SPDX-License-Identifier: MIT
# 
BUILD_DIR=build

usage_exit() {
    echo "run_crops.sh [-b build] -- [commands]"
    echo " -b: a build directory of poky"
    exit 0
}

while getopts b:h OPT
do
    case ${OPT} in
        b) BUILD_DIR=${OPTARG}
           ;;
        h) usage_exit
           ;;
        \?) usage_exit
            ;;
    esac
done
shift $((OPTIND - 1))
echo "BUILD_DIR =" "${BUILD_DIR}"


cmd="source $(pwd)/poky/oe-init-build-env ${BUILD_DIR}"
if [ $# -gt 0 ] ; then
	cmd="${cmd} && $*"
fi

docker run --rm -it -v "$(pwd)":"$(pwd)" crops/poky:ubuntu-20.04 --workdir="$(pwd)" bash -c "${cmd}"
