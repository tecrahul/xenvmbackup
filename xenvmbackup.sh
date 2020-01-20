#!/bin/bash
#
# Written By: Mr Rahul Kumar
# Created date: Jun 14, 2014
# Last Updated: Mar 08, 2017
# Version: 1.2.1
# Visit: https://tecadmin.net/backup-running-virtual-machine-in-xenserver/
#

DATE=`date +%d%b%Y`
XSNAME=`echo $HOSTNAME`
UUIDFILE=/tmp/xen-uuids.txt
NFS_SERVER_IP="192.168.10.100"
MOUNTPOINT=/xenmnt
FILE_LOCATION_ON_NFS="/backup/citrix/vms"

# Loglevel 0=only exit 0
# Loglevel 1=every action

LOGLEVEL=0

### Create mount point

[ $LOGLEVEL -ne 0 ] && echo "create mountpoint " $MOUNTPOINT " if not exist"
mkdir -p ${MOUNTPOINT}

### Mounting remote nfs share backup drive

[ ! -d ${MOUNTPOINT} ]  && echo "No mount point found, kindly check"; exit 0
[ $LOGLEVEL -ne 0 ] && echo "mount NFS " $NFS_SERVER_IP":"$FILE_LOCATION_ON_NFS
mount -F nfs ${NFS_SERVER_IP}:${FILE_LOCATION_ON_NFS} ${MOUNTPOINT}

BACKUPPATH=${MOUNTPOINT}/${XSNAME}/${DATE}
[ $LOGLEVEL -ne 0 ] && echo "create backuppath " $BACKUPPATH " if not exist"
mkdir -p ${BACKUPPATH}
[ ! -d ${BACKUPPATH} ]  && echo "No backup directory found"; exit 0

# Fetching list UUIDs of all VMs running on XenServer
[ $LOGLEVEL -ne 0 ] && echo "create UuidFile " ${UUIDFILE}
xe vm-list is-control-domain=false is-a-snapshot=false | grep uuid | cut -d":" -f2 > ${UUIDFILE}

[ ! -f ${UUIDFILE} ] && echo "No UUID list file found"; exit 0

while read VMUUID
do
    VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`

    SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="SNAPSHOT-$VMUUID-$DATE"`

    [ $LOGLEVEL -ne 0 ] && echo "create snapshoot from: " $VMNAME
    xe template-param-set is-a-template=false ha-always-run=false uuid=${SNAPUUID}

    [ $LOGLEVEL -ne 0 ] && echo "export snapshoot " $VMNAME "to " $BACKUPPATH
    xe vm-export vm=${SNAPUUID} filename="$BACKUPPATH/$VMNAME-$DATE.xva"

    [ $LOGLEVEL -ne 0 ] && echo "remove snapshoot from: " $VMNAME
    xe vm-uninstall uuid=${SNAPUUID} force=true

done < ${UUIDFILE}

[ $LOGLEVEL -ne 0 ] && echo "unmount NFS " $MOUNTPOINT
umount ${MOUNTPOINT}
[ $LOGLEVEL -ne 0 ] && echo "Xen Server VM Backup finished"
