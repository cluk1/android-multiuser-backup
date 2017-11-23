#!/bin/bash

. $(dirname $0)/config

set -e

rm -rf $localdatadir;
adb shell su -c \'rm -rf $devdatadir\'
adb push $(dirname $0)/backup.sh $devtmpdir/
adb push $(dirname $0)/config $devtmpdir/
adb shell su -c \'sh $devtmpdir/backup.sh $*\'
adb pull $devdatadir $localdatadir
adb shell su -c \'rm -rf $devdatadir\'
adb shell rm -f $devtmpdir/backup.sh
adb shell rm -f $devtmpdir/config
