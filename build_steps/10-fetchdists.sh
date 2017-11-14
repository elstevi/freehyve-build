#!/bin/sh

set -x
set -e

RELEASE="11.1-RELEASE"
DISTS="kernel.txz base.txz MANIFEST"

for DIST in $DISTS; do
	#fetch -m -o ${DIST_DROP_DIR} "http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/11.1-RELEASE/${DIST}"
done
