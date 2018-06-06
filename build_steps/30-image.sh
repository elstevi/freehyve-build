#!/bin/sh
set -e
set -x

BUILDER_TZ="America/Los_Angeles"
IMG_SIZE="8100M"
NCPU=`sysctl -n hw.ncpu`
SWAP_SIZE="2G"
ZPOOL_NAME="freehyveboot"
ZFS_ROOT_DS="${ZPOOL_NAME}/root/${FREEHYVE_VERS}"
ZFS_PERSIST_DS="${ZPOOL_NAME}/persist"
DESTDIR="/tmp/install/"

mkdir -p ${DESTDIR}

#### Create the image and back it by an md
truncate -s ${IMG_SIZE} ${IMAGE_DROP_DIR}/freehyve_${FREEHYVE_VERS}.img
MD_DEV=`mdconfig -f ${IMAGE_DROP_DIR}/freehyve_${FREEHYVE_VERS}.img | tr -d "\n"`

#### Partition the disk image
gpart create -s gpt /dev/${MD_DEV}
gpart add -s 512K -t freebsd-boot -i 1 /dev/${MD_DEV}
gpart add -s 7G -t freebsd-zfs -i 2 /dev/${MD_DEV}

zpool create -f -o cachefile=/tmp/zpool.cache -o altroot=${DESTDIR} ${ZPOOL_NAME} /dev/${MD_DEV}p2
zpool set autoreplace=on ${ZPOOL_NAME}
zpool set autoexpand=on ${ZPOOL_NAME}
zfs set mountpoint=none ${ZPOOL_NAME}
zfs create -p ${ZFS_ROOT_DS}
zfs set compression=lz4 ${ZPOOL_NAME}
zfs set mountpoint=/ ${ZFS_ROOT_DS}
zfs create -p -o mountpoint=/persist ${ZFS_PERSIST_DS}
zfs create -p ${ZFS_PERSIST_DS}/vms
zfs create -p -o mountpoint=/home ${ZFS_PERSIST_DS}/home
zfs create -p -o reservation=1G ${ZFS_PERSIST_DS}/ballast
zfs create -p -o mountpoint=/var/log ${ZFS_PERSIST_DS}/log
zfs create -p -o mountpoint=/etc/ssh ${ZFS_PERSIST_DS}/ssh

### Set bootfs 
zpool set bootfs=${ZFS_ROOT_DS} ${ZPOOL_NAME}

### Set up swap
zfs create -V ${SWAP_SIZE} -o refreservation=none ${ZPOOL_NAME}/swap
zfs set org.freebsd:swap=on ${ZPOOL_NAME}/swap

### Install base and kernel
tar -C ${DESTDIR} --unlink -xpJf ${DIST_DROP_DIR}/base.txz
tar -C ${DESTDIR} --unlink -xpJf ${DIST_DROP_DIR}/kernel.txz

zfs create -p -o mountpoint=/root ${ZFS_PERSIST_DS}/root
find ${DESTDIR}/usr/share/skel/dot.* | rev | cut -d \. -f1 | rev | xargs -I % cp ${DESTDIR}/usr/share/skel/dot.% ${DESTDIR}/root/%

sysctl kern.geom.debugflags=0x10

gpart bootcode -b ${DESTDIR}/boot/pmbr -p ${DESTDIR}/boot/gptzfsboot -i 1 /dev/${MD_DEV}

### Packages
cp /etc/resolv.conf ${DESTDIR}/etc/resolv.conf
mkdir -p ${DESTDIR}/etc/pkg/
echo "freehyve: {
        url: \"file://${ARTIFACT_DIR}/packages/packages/packages/base-local\",
        mirror_type: \"none\",
        enabled: yes
}" > ${DESTDIR}/etc/pkg/freehyve.conf
mv ${DESTDIR}/etc/pkg/FreeBSD.conf ${DESTDIR}/tmp/FreeBSD.conf

mkdir -p "${DESTDIR}/${ARTIFACT_DIR}"
mount -t nullfs ${ARTIFACT_DIR} ${DESTDIR}/${ARTIFACT_DIR}
export ASSUME_ALWAYS_YES="yes"
pkg -c ${DESTDIR} install -y `cat poudriere/host_packages.txt | tr '\n' ' '`
umount "${DESTDIR}/${ARTIFACT_DIR}"
rm ${DESTDIR}/etc/pkg/freehyve.conf
mv ${DESTDIR}/tmp/FreeBSD.conf ${DESTDIR}/etc/pkg/FreeBSD.conf
### Set timezone
tzsetup -C ${DESTDIR} ${BUILDER_TZ} 

#### Disallow password authentication for root
echo 'a' | pw -R ${DESTDIR} mod user root -h 0

#### Overlay some config files
cp -R overlay/* ${DESTDIR}/

git clone https://github.com/novnc/noVNC.git ${DESTDIR}/usr/local/www/noVNC

# Upgrade pip
chroot ${DESTDIR} /usr/local/bin/pip install -U pip
PIP_PACKAGES="libbhyve.git bapi.git bapiclient.git bweb.git bcli.git"
for PACKAGE in $PIP_PACKAGES; do
	chroot ${DESTDIR} /usr/local/bin/pip install git+https://github.com/elstevi/${PACKAGE}@master
done

#### Create a very small receipt
echo "${FREEHYVE_VERS}" > ${DESTDIR}/receipt
echo "freehyve rev: #${FREEHYVE_VERS}" >> ${DESTDIR}/etc/motd

### Send the update zfs pool to a string
zfs umount -f ${ZFS_ROOT_DS}
zfs set mountpoint=none ${ZFS_ROOT_DS}
zfs snapshot -r ${ZFS_ROOT_DS}@update
zfs send -R ${ZFS_ROOT_DS}@update | xz -9 --threads ${NCPU} > ${IMAGE_DROP_DIR}/freehyve_${FREEHYVE_VERS}_update.zfs.xz
zfs set mountpoint=/ ${ZFS_ROOT_DS}

### Export the zpool
mkdir -p ${DESTDIR}/boot/zfs/
mv /tmp/zpool.cache ${DESTDIR}/boot/zfs/
sync
zpool export ${ZPOOL_NAME}
sync

### Delete the memory disk
mdconfig -d -u `echo ${MD_DEV} | cut -d d -f2 | tr -d "\n"`
xz -9 --threads=${NCPU} ${IMAGE_DROP_DIR}/freehyve_${FREEHYVE_VERS}.img

