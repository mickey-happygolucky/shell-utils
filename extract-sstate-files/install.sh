#!/bin/bash -e

BIN_DSTDIR=/opt/hashserv
DATA_DSTDIR=/var/www/html/data
UNIT_DSTDIR=/etc/systemd/system

function usage_exit() {
    echo "Usage: $0 [-uh]"
    echo "       -u(--uninstall): uninstall"
    echo "       -h(--help)     : help(this message)"
    exit 0
}

function check_args() {
    declare args
    args=$(getopt -o uh -l uninstall,help -- "$@") || exit 22
    eval set -- "$args"

    # loop for parsing
    while [ $# -gt 0 ]; do
        case $1 in
	    -u | --uninstall)
		uninstall_exit
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

function install_hashserv() {
    declare libdir="${BIN_DSTDIR}/lib"
    declare bindir="${BIN_DSTDIR}/bin"

    if [ ! -e "${BIN_DSTDIR}" ]; then
	sudo mkdir -p "${BIN_DSTDIR}"
	echo "${BIN_DSTDIR} is created"
    fi
    if [ -e "${libdir}" ]; then
	echo "installing ${libdir} is skipped."
    else
	sudo cp -a "${PWD}/../lib" "${BIN_DSTDIR}"
	echo "${libdir} is installed"
    fi
    if [ -e "${bindir}" ]; then
	echo "installing ${bindir} is skipped."
    else
	sudo cp -a "${PWD}/../bin" "${BIN_DSTDIR}"
	echo "${bindir} is installed"
    fi

}

function install_servicefile() {
    declare servicefile="${UNIT_DSTDIR}/hashserv.service"
    if [ -e "${servicefile}" ]; then
	echo "${servicefile} installing is skipped."
	return
    fi
    sudo cp -a "${PWD}/hashserv.service" "${servicefile}"
}

function install_data() {
    declare hashservdb="${DATA_DSTDIR}/hashserv.db"
    declare sstatecache="${DATA_DSTDIR}/sstate-cache"

    if [ ! -e "${DATA_DSTDIR}" ]; then
	sudo mkdir -p "${DATA_DSTDIR}"
	echo "${DATA_DSTDIR} is created."
    fi
    if [ -e "${hashservdb}" ]; then
       sudo rm -f "${hashservdb}"
       echo "${hashservdb} is deleted."
    fi
    if [ -e "${sstatecache}.bak" ]; then
	sudo rm -rf "${sstatecache}.bak"
	echo "${sstatecache}.bak is deleted."
    fi
    if [ -e "${sstatecache}" ]; then
	sudo mv "${sstatecache}" "${sstatecache}.bak"
	echo "renamed ${sstatecache} -> ${sstatecache}.bak"
    fi
    echo -n "installing..."
    sudo cp -a "${PWD}/hashserv.db" ${hashservdb}
    sudo cp -a  "${PWD}/sstate-cache" ${sstatecache}
    echo "done."
}

function activate_service() {
    sudo systemctl restart hashserv.service
    sudo systemctl enable hashserv.service
    echo "activate done."
}

function uninstall_exit() {
    declare servicefile="${UNIT_DSTDIR}/hashserv.service"
    declare hashservdb="${DATA_DSTDIR}/hashserv.db"
    declare sstatecache="${DATA_DSTDIR}/sstate-cache"
    if [ -e ${BIN_DSTDIR} ]; then
	sudo rm -rf ${BIN_DSTDIR}
	echo "${BIN_DSTDIR} is deleted."
    fi
    if [ -e ${servicefile} ]; then
	sudo systemctl stop hashserv.service
	sudo systemctl disable hashserv.service
	sudo rm -f ${servicefile}
	echo "${servicefile} is deleted."
    fi
    if [ -e ${hashservdb} ]; then
	sudo rm -f ${hashservdb}
	echo "${hashservdb} is deleted."
    fi
    if [ -e ${sstatecache} ]; then
	sudo rm -rf ${sstatecache}
	echo "${sstatecache} is deleted."
    fi
    if [ -e ${sstatecache}.bak ]; then
	sudo rm -rf ${sstatecache}.bak
	echo "${sstatecache}.bak is deleted."
    fi
    echo "uninstalling done."
    exit 0
}

check_args "$@"
install_hashserv
install_servicefile
install_data
activate_service
