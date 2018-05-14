#!/bin/sh
set -e
set -x

cd ${WORKSPACE}/installer
mkdir tmp work
make -f Makefile.freehyve_installer
cp *.xz ${INSTALLER_DROP_DIR}
