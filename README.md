# freehyve-build

## Description

Builds a BSD Hypervisor operating system image, combining the following:
* [FreeBSD](https://freebsd.org) - operating system
* [bhyve](https://bhyve.org) - hypervisor
* [libbhyve](https://github.com/elstevi/libbhyve) - python bindings to bhyve
* [bweb](https://github.com/elstevi/bweb) - python web interface for bhyve
* [bapi](https://github.com/elstevi/bapi) - python web api to libbhyve
* [bapiclient](https://github.com/elstevi/bapiclient) - python client to bapi
* [bcli](https://github.com/elstevi/bcli) - python click cli interface to libbhyve

## Project anatomy

### freehyve-build.sh 
Sets the version number, kicks off all other build steps

#### build\_steps/10-fetchdists.sh
Fetches upstream distribution files from the specified release.

#### build\_steps/20-packages.sh
Locally builds binary packages that the hypervisor requires using poudriere.

#### build\_steps/30-image.sh
Builds a gpt/zfs image that can be plastered on to any media larger that 8GB. Also includes a zfs update image that will utilize freehyve-update to download a new boot environment.

### overlay/
These files are overlayed over the root of the new filesystem.

### poudriere/
Contains a package list for the hypervisor, various poudriere configurations. This directory is considered the -e poudriereetc directory by the build scripts.

## Building

Simply set the version in freehyve-build.sh, and then execute the shell script on any FreeBSD 11+ system.

### Building individual components
If you have done a full build once (and not cleaned up), you can build individual components by executing

```sh freehyve-build.sh exec```

This puts you into the environment necessary to run a build. Just run

```sh build_steps/desired_step.sh```

## Installing
The completed image can be installed on a system by running something like this:

```
#!/bin/sh                    
DISK="/dev/ada0"             
TEST_POOL="test"             
zpool create -f ${TEST_POOL} ${DISK}p2                     
zpool destroy ${TEST_POOL}   
gpart destroy -F ${DISK}     

gzcat path_to_image.img.gz | dd bs=4M of=/dev/ada0 
```

This should probably be split into an installer at some point, and an additional build_step.

## Firstboot
The first time the system comes up, it will attempt to grow the zpool to fill the entiredisk.
