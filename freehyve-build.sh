#!/bin/sh

set -x
set -e

export WORKSPACE=$WORKSPACE
export ARTIFACT_DIR="/root/build"
export WORK_DIR="${WORKSPACE}/work"
export VERSION="12.0-CURRENT"
export FREEHYVE_VERS="0.0.1zi"
export DIST_DROP_DIR="${ARTIFACT_DIR}/freebsd"
export PACKAGE_DROP_DIR="${ARTIFACT_DIR}/packages"
export IMAGE_DROP_DIR="${ARTIFACT_DIR}/image"

mkdir -p $ARTIFACT_DIR $WORK_DIR $DIST_DROP_DIR $PACKAGE_DROP_DIR $IMAGE_DROP_DIR

if [ "${1}" == "exec" ]; then
	sh
else
	for SCRIPT in `ls build_steps/*.sh`; do
		echo ">> running script ${SCRIPT}"
		sh "${SCRIPT}"
		echo ">> script finished ${SCRIPT}"
	done
fi

