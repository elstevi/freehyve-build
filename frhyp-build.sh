#!/bin/sh

set -x
set -e

export ARTIFACT_DIR="/tmp/build"
export WORK_DIR="/tmp/work"
export VERSION="11.1-RELEASE"
export FRHYP_VERS="0.0.1s"
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

