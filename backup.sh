#!/bin/sh

set -e

. $(dirname $0)/config

uid=$1
shift
pkgarg=$1

if [ -z "$uid" -o -z "$pkgarg" ]; then
  echo "Usage $0 <uid> <pkg>"
  exit 0
fi


base="$devdatadir"
mkdir -p $base/{apks,data}

cd /data
pkgs="$*"
uids="$uid"
alluids=0

if [ "$uid" = "all" ]; then
  alluids=1
  uids="$(pm list users | grep 'UserInfo' | cut -f1 -d':' | cut -f2 -d'{')"
fi

for uid in $uids; do
  echo "Creating backup for uid $uid.."
  mkdir -p $base/data/$uid
  
  # Backup all installed packages?
  if [ "$pkgarg" = "all" ]; then
    pkgs="$(pm list packages --user "$uid" | cut -f2 -d':')"
  fi

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
  # This is for old Android.
  if [ -f "/data/system/users/$uid/accounts.db" ]; then
    echo "Creating backup of accounts.db .."
    tar -cf "$base/data/$uid/accounts.db.tar" "/data/system/users/$uid/accounts.db"
    echo "done."
  fi
  # Newer Android (like Android 9).
  if [ -f "/data/system_ce/$uid/accounts_ce.db" ]; then
    echo "Creating backup of accounts_ce.db .."
    tar -cf "$base/data/$uid/accounts_ce.db.tar" "/data/system_ce/$uid/accounts_ce.db"
    echo "done."
  fi
  if [ -f "/data/system_de/$uid/accounts_de.db" ]; then
    echo "Creating backup of accounts_de.db .."
    tar -cf "$base/data/$uid/accounts_de.db.tar" "/data/system_de/$uid/accounts_de.db"
    echo "done."
  fi
done
if [ -f "/data/system/sync/accounts.xml" ]; then
  echo "Creating backup of accounts.xml ..."
  tar -cf "$base/data/accounts.xml.tar" "/data/system/sync/accounts.xml"
  echo "done."
fi

find $base
