#!/bin/bash
#
# Written By: Mr Rahul Kumar
# Created date: Jun 14, 2014
# Last Updated: Jan 22, 2016
# Version: 1.2
# Visit: https://tecadmin.net
#

DATE=`date +%d%b%Y`
XSNAME=`echo $HOSTNAME`
MOUNTPOINT=/xenmnt
UUIDFILE=/tmp/xen-uuids.txt
NFS_SERVER_IP="192.168.10.100"

### Create mount point

mkdir -p ${MOUNTPOINT}

### Mounting remote nfs share backup drive

[ ! -d ${MOUNTPOINT} ]  && echo "No mount point found, kindly check"; exit 0
mount -F nfs ${NFS_SERVER_IP}:/backup/citrix/vms ${MOUNTPOINT}

BACKUPPATH=${MOUNTPOINT}/${XSNAME}/${DATE}
mkdir -p ${BACKUPPATH}
[ ! -d ${BACKUPPATH} ]  && echo "No backup directory found"; exit 0


# Fetching list UUIDs of all VMs running on XenServer
xe vm-list is-control-domain=false is-a-snapshot=false | grep uuid | cut -d":" -f2 > ${UUIDFILE}

[ ! -f ${UUIDFILE} ] && echo "No UUID list file found"; exit 0

while read VMUUID
do
    VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`

    SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="SNAPSHOT-$VMUUID-$DATE"`

    xe template-param-set is-a-template=false ha-always-run=false uuid=${SNAPUUID}

    xe vm-export vm=${SNAPUUID} filename="$BACKUPPATH/$VMNAME-$DATE.xva"

    xe vm-uninstall uuid=${SNAPUUID} force=true

done < ${UUIDFILE}

umount ${MOUNTPOINT}
