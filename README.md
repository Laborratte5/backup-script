# backup-script
Bash script to create squashfs compressed archives of block device images.

This script will generate an image file of the backup destination
and add it to a squash compressed filesystem.

# Why
I like doing full disk backups from time to time. This way I can't miss
any important files. Moreover this also backups the complete partition layout and
LUKS Headers if they exists on a system.
The problem is full disk images can get quite big, even if there is not much space
used on the disk. Therefore compressing images does make sense. However by simply
gzipping images one is not be able to simply mount the image in case access to a
single file is needed.

By using squashfs this is circumventet.
The squashfs can be mounted in a compressed state being completly transparend
to the user (besides being read-only).

When the squasfs is mounted the image file can be mounted as if it existed
uncompressed. By again mounting the image file (using e.g. loopback devices)
it is possible to access browse/access single files inside the compressed
full disk backup.

This script was created because I could not remember the commands used to create
such a compressed image and got tired of searching every time.

# Usage
The script is used interactively.
The user will be prompted for everything that is needed to create the backup.


```bash
# ./backup.sh
Backup source: /dev/sda1
Backup destination: /mnt/backupOfsda1
```
