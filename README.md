## Xen Server VM Backup

This is a simple bash/shell script to backup running virtual machines on Xen Servers. This script takes backup of virtual machine and store backup on NFS server. 



## How to Use Script

Download this script and modify some parameters as per your network and directory structure.

MOUNTPOINT=/xenmnt   ## change this with your system mount point
UUIDFILE=/tmp/xen-uuids.txt   ## You may change this also
NFS_SERVER_IP="192.168.10.100"   ## IP of your NFS server.
FILE_LOCATION_ON_NFS="/backup/citrix/vms"  ## Location to store backups on NFS server.


Now execute the script from command line

> $ sh xenvmbackup.sh 

You may also schedule this with crontab to run as per backup frequency. 

> 0 2 * * * /bin/sh xenvmbackup.sh
  
  
## Author
 
 For more details about this script visit to
 
 https://tecadmin.net/backup-running-virtual-machine-in-xenserver/
