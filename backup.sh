#!/bin/bash
read -e -p "Backup source: " DRIVE_TO_BACKUP
read -e -p "Backup destination: " BACKUP_LOCATION

DEVICE_NAME=$(basename $DRIVE_TO_BACKUP)

# Create empty dir
empty_dir=$(mktemp -d)

BACKUP_LOCATION="${BACKUP_LOCATION}-$(date +'%Y-%m-%d').sqsh"
CHECKSUM_FILE="$DEVICE_NAME.img.cksum"

echo
echo Backup source: $DRIVE_TO_BACKUP
echo Backup destination: $BACKUP_LOCATION
echo

echo Check if your input is correct
echo Double check the correct usage of source and destination
echo \"Backup source\" is the drive you want to backup
echo \"Backup destination\" is where the backup will be stored
read -n1 -r -s -p $"Press space to continue..."

mksquashfs $empty_dir $BACKUP_LOCATION -p "$DEVICE_NAME.img f 444 root root dd if=$DRIVE_TO_BACKUP bs=4M" -p "$CHECKSUM_FILE f 444 root root dd if=$DRIVE_TO_BACKUP | cksum"

# Check Backup integrity by mounting and recalculating checksum from img and dev and compare to .img .img.cksum dev
echo
echo Checking Backup integrity ...
echo

BACKUP_MNT=$(mktemp -d)
mount -o ro $BACKUP_LOCATION $BACKUP_MNT

# Recalculate checksums
DRIVE_CKSUM=$(dd if=$DRIVE_TO_BACKUP | cksum)

# Compare checksums
diff <(echo $DRIVE_CKSUM) <(cat $BACKUP_MNT/$CHECKSUM_FILE)
if [ $? -ne 0 ]; then
	echo -e "\e[1;41m Backup not consistent! \e[0m"
	exit 1
fi

# Recalculate checksums
IMG_CKSUM=$(dd if=$BACKUP_MNT/$DEVICE_NAME.img | cksum)

# Compare checksums
diff <(echo $IMG_CKSUM) <(cat $BACKUP_MNT/$CHECKSUM_FILE)
if [ $? -ne 0 ]; then
	echo -e "\e[1;41m Backup not consistent! \e[0m"
	exit 1
fi

umount $BACKUP_LOCATION

echo -e "\e[1;42m Backup complete \e[0m"

