#!/bin/sh
set -e
set -x

cd ${WORKSPACE}/installer
mkdir tmp work
make -f Makefile.freehyve_installer
make -f Makefile.freehyve_installer iso

cp *.img ${INSTALLER_DROP_DIR}
cp *.iso ${INSTALLER_DROP_DIR}
