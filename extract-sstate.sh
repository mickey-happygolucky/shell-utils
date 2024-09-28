#!/bin/bash

DSTDIR=/tmp/hashserv
DSTDIR_BIN=${DSTDIR}/bin
DSTDIR_LIB=${DSTDIR}/lib
DSTDIR_DAT=${DSTDIR}/data
SRCDIR=""
SUBDIR=""

function find_bitbake() {
    declare dir="../"
    declare path
    declare bitbake
    
    while  : ; do
	path=$(find ${dir} -maxdepth 2 -a -name 'poky' -a -type d)
	[[ -z ${path} ]] || break
	dir="${dir}../"
    done
    bitbake=$(find "${path}" -name 'bitbake' -a -type d)
    [[ -n ${bitbake} ]] || exit 2
    echo "${bitbake}"
}

function extract_hashserv() {
    if [ -e  ${DSTDIR} ]; then
	rm -rf ${DSTDIR}
	echo "${DSTDIR} is deleted."
    fi

    if [ -f  ${DSTDIR}.tar.gz ]; then
	rm -f ${DSTDIR}.tar.gz
	echo "${DSTDIR.tar.gz} is deleted."
    fi

    mkdir -p ${DSTDIR_BIN}
    mkdir -p ${DSTDIR_LIB}
    mkdir -p ${DSTDIR_DAT}

    echo -n "extracting ..."
    cp -a "${SRCDIR}/bin/bitbake-hashserv" ${DSTDIR_BIN}/
    cp -a "${SRCDIR}/lib/hashserv" ${DSTDIR_LIB}/hashserv/
    cp -a "${SRCDIR}/lib/bb" ${DSTDIR_LIB}/bb/
    cp -a "${SRCDIR}/lib/codegen.py" ${DSTDIR_LIB}/codegen.py
    cp -a "${SRCDIR}/lib/ply" ${DSTDIR_LIB}/ply/
    cp -a "${SRCDIR}/lib/bs4" ${DSTDIR_LIB}/bs4/
    cp -a sstate-cache ${DSTDIR_DAT}/sstate-cache
    cp -a cache/hashserv.db ${DSTDIR_DAT}/
    echo "done."
}

function find_subdir() {
    declare path
    declare srcdir

    path=$(realpath "$0")
    srcdir=$(dirname "${path}")
    echo "${srcdir}/extract-sstate-files"

}

function gen_servicefile(){
    declare srcfile="${SUBDIR}/hashserv.service"
    declare servicefile=${DSTDIR}/data/hashserv.service
    cp -a "${srcfile}" "${servicefile}"
    echo "${servicefile} is generated."
}

function gen_installer() {
    declare srcfile="${SUBDIR}/install.sh"
    declare installer=${DSTDIR}/data/install.sh
    cp -a "${srcfile}" "${installer}"
    echo "${installer} is generated."
}

function archive_data() {
    cd ${DSTDIR}/.. || exit 1
    tar -I pigz -v -cf hashserv.tar.gz ./hashserv
}

SRCDIR=$(find_bitbake)
SUBDIR=$(find_subdir)
echo "bitbake = ${SRCDIR}"
echo "subdir  = ${SUBDIR}"
extract_hashserv
gen_servicefile
gen_installer
archive_data
