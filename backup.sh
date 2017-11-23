#!/bin/sh

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

# Backup all installed packages?
if [ "$pkg" = "all" ]; then
  pkgs="$(pm list packages | cut -f2 -d':')"
fi

echo "Creating backup for uid $uid.."
mkdir -p $base/data/$uid
for pkg in $pkgs; do
  [ -f /data/app/$pkg-*/base.apk ] && (
    echo "  Backing up pkg $pkg.."
    cp /data/app/$pkg-*/base.apk $base/apks/$pkg.apk
    [ -d "user/$uid/$pkg" ] && (
      echo "    Backing up userdata.."
      tar c -C user/$uid -f $base/data/$uid/$pkg-user.tar $pkg
      echo "    done."
    )
    [ -d "media/$uid/Android/data/$pkg" ] && (
      echo "    Backing up media.."
      tar c -C media/$uid/Android/data -f $base/data/$uid/$pkg-media.tar $pkg
      echo "    done."
    )
    echo "  done."
  )
done
echo "done."

ls -lah $base
