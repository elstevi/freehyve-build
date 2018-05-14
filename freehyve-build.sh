#!/bin/sh

set -x
set -e

export WORKSPACE=$WORKSPACE
export ARTIFACT_DIR="${WORKSPACE}/artifacts"
export WORK_DIR="${WORKSPACE}/work"
export VERSION="12.0-CURRENT"
if [ -z ${BUILD_NUMBER+x} ]; then
export FREEHYVE_VERS="0.0.1zi"
else
	export FREEHYVE_VERS="0.0.1-${BUILD_NUMBER}"
fi

export DIST_DROP_DIR="${ARTIFACT_DIR}/freebsd"
export PACKAGE_DROP_DIR="${ARTIFACT_DIR}/packages"
export IMAGE_DROP_DIR="${ARTIFACT_DIR}/image"
export INSTALLER_DROP_DIR="${ARTIFACT_DIR}/installer"

mkdir -p $ARTIFACT_DIR $WORK_DIR $DIST_DROP_DIR $PACKAGE_DROP_DIR $IMAGE_DROP_DIR $INSTALLER_DROP_DIR

if [ "${1}" == "exec" ]; then
	sh
else
	for SCRIPT in `ls build_steps/*.sh`; do
		echo ">> running script ${SCRIPT}"
		sh "${SCRIPT}"
		echo ">> script finished ${SCRIPT}"
	done
fi

