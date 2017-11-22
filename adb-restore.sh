#!/bin/bash

. $(dirname $0)/config

set -e

adb shell su -c rm -rf $devdatadir
adb push $localdatadir/ $devdatadir/
adb push $(dirname $0)/restore.sh $devtmpdir/
adb push $(dirname $0)/config $devtmpdir/
adb shell su -c sh $devtmpdir/restore.sh $*
adb shell su -c rm -rf $devdatadir
adb shell rm -f $devtmpdir/restore.sh
adb shell rm -f $devtmpdir/config

