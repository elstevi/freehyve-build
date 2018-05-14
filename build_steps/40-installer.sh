#!/bin/sh
set -e
set -x

cd ${WORKSPACE}/installer
make -f Makefile.freehyve_installer
cp *.xz ${INSTALLER_DROP_DIR}
