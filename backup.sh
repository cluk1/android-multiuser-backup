#!/bin/sh

set -e

. $(dirname $0)/config

uid=$1
shift
pkg=$1

if [ -z "$uid" -o -z "$pkg" ]; then
  echo "Usage $0 <uid> <pkg>"
  exit 0
fi


base="$devdatadir"
mkdir -p $base/{apks,data}

cd /data
pkgs="$*"
uids="$uid"
alluids=0

# Backup all installed packages?
if [ "$pkg" = "all" ]; then
  pkgs="$(pm list packages | cut -f2 -d':')"
fi

if [ "$uid" = "all" ]; then
  alluids=1
  uids="$(pm list users | grep 'UserInfo' | cut -f1 -d':' | cut -f2 -d'{')"
fi

for uid in $uids; do
  echo "Creating backup for uid $uid.."
  mkdir -p $base/data/$uid
  for pkg in $pkgs; do
    if [ -f /data/app/$pkg-*/base.apk ]; then
      echo "  Backing up pkg $pkg.."
      if [ ! -f "$base/apks/$pkg.apk" ]; then
        echo "    Backing up apk.."
        cp /data/app/$pkg-*/base.apk $base/apks/$pkg.apk
        echo "    done."
      else
        echo "    apk already backed up."
      fi
      if [ ! -z "$(pm list package -e --user $uid $pkg)" ]; then
        if [ -d "user/$uid/$pkg" ]; then
          echo "    Backing up userdata.."
          tar c -C user/$uid -f $base/data/$uid/$pkg-user.tar $pkg
          echo "    done."
        fi
        if [ -d "media/$uid/Android/data/$pkg" ]; then
          echo "    Backing up media.."
          tar c -C media/$uid/Android/data -f $base/data/$uid/$pkg-media.tar $pkg
          echo "    done."
        fi
      else
        echo "    pkg $pkg is not enabled for user $uid"
        touch $base/data/$uid/$pkg.disabled
      fi
      echo "  done."
    fi
  done
  echo "done."
  if [ -f "/data/system/users/$uid/accounts.db" ]; then
    echo "Creating backup of accounts.db .."
    cp /data/system/users/$uid/accounts.db $base/data/$uid/
    echo "done."
  fi
done
if [ -f "/data/system/sync/accounts.xml" ]; then
  echo "Creating backup of accounts.xml .."
  cp /data/system/sync/accounts.xml $base/data/
  echo "done."
fi

find $base
