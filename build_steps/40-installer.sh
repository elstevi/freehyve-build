#!/bin/sh
set -e
set -x

cd ${WORKSPACE}/installer
mkdir tmp work
make -f Makefile.freehyve_installer
cp *.img ${INSTALLER_DROP_DIR}
