#!/bin/sh

set -x
set -e

poudriere version
rsync --version

# This is where the manifest from our build should be
JAIL_NAME="base"

PORTS_NAME="local"

# Generate poudriere command
POUDRIERE=`which poudriere`" -e "`readlink -f poudriere/`

# Create poudriere jails
${POUDRIERE} jail -c -j ${JAIL_NAME} -m tar=${DIST_DROP_DIR}/base.txz -v ${VERSION}

# Checkout ports tree
${POUDRIERE} ports -c -p ${PORTS_NAME} > /dev/null

# Patch nginx for websockify
patch -i poudriere/ports-patches/websockify-nginx-port.patch /usr/local/poudriere/ports/local/www/nginx/Makefile
cat poudriere/ports-patches/distinfo-nginx >> /usr/local/poudriere/ports/local/www/nginx/distinfo

#Create ports distfile
mkdir -p /usr/ports/distfiles

# Generate packages
${POUDRIERE} bulk -j ${JAIL_NAME} -p ${PORTS_NAME} -f poudriere/host_packages.txt

# Copy packages off of system
mv /usr/local/poudriere/data /usr/local/poudriere/packages
rsync -av --progress /usr/local/poudriere/packages ${PACKAGE_DROP_DIR}

# Destroy jails
yes | ${POUDRIERE} jail -d -j ${JAIL_NAME}
yes | ${POUDRIERE} ports -d -p $PORTS_NAME
rm -rf /usr/local/poudriere

