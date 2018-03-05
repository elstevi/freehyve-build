#!/bin/sh

set -x
set -e

BRANCH="master"
NCPU=`sysctl -n hw.ncpu`
REPO="https://github.com/freebsd/freebsd.git"
SRCDIR="${WORK_DIR}/src"

mkdir -p ${SRCDIR}

git clone -b ${BRANCH} ${REPO} ${SRCDIR}
cd ${SRCDIR}; patch < /root/src/freehyve-build/freebsd/bhyve-random-port.patch
cd ${SRCDIR}; make -j ${NCPU} buildworld
cd ${SRCDIR}; make -j ${NCPU} buildkernel
cd ${SRCDIR}/release; make -j ${NCPU} packagesystem

cp -R ${SRCDIR}/release/*.txz ${DIST_DROP_DIR}
cp -R ${SRCDIR}/release/MANIFEST ${DIST_DROP_DIR}
