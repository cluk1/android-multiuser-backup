# cluk33/android-multiuser-backup

**a set of shell scripts to backup and restore apps and data for multiuser android devices**

## Motivation
I spend hours to find a way to copy all data from all useraccounts from my old tablet to the new one.
Neither adb backup, nor Titanium Backup or oandbackup worked correctly.

Titanium need supersu for every user and does not backup data for users which
are not the device owner (userid!=0).

Oandbackup also needs supersu. It backs up data from /data/user but after running
a restore the restored apps crash because of permission problems in /data/user.
The directory and file ownership and permissions in /data/user are restored
correctly but the selinux context information is missing which makes the files
inaccessible by the app process. You can see a lot of 'permission denied' errors
in the logcat.

## Prerequisites
The shell scripts in this repo require
- a rooted device,
- a working adb connection and
- su working in the adb shell.

## Backup
After cloning the repo you could simply run:
```bash
  adb-backup.sh <uid> <pkg1> [<pkg2> <pkg3> ..]
```
eg:
```bash
  adb-backup.sh 12 org.mozilla.firefox com.foo.bar
```
## Restore
```bash
  adb-restore.sh <uid> <pkg1> [<pkg2> <pkg3> ..]
```

eg:
```bash
  adb-restore.sh 12 org.mozilla.firefox com.foo.bar
```
