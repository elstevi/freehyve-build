#!/bin/sh

set -x
set -e

BRANCH="master"
NCPU=`sysctl -n hw.ncpu`
REPO="/root/freebsd"
SRCDIR="${WORK_DIR}/src"
mkdir -p ${SRCDIR}

git clone -b ${BRANCH} ${REPO} ${SRCDIR}
cd ${SRCDIR}; make -j ${NCPU} buildworld
cd ${SRCDIR}; make -j ${NCPU} buildkernel
cd ${SRCDIR}/release; make packagesystem

cp -R /usr/obj/${SRCDIR}/amd64.amd64/release/*.txz ${DIST_DROP_DIR}
cp -R /usr/obj/${SRCDIR}/amd64.amd64/release/MANIFEST ${DIST_DROP_DIR}
