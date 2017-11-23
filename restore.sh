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

cd /data
pkgs="$*"

# Backup all installed packages?
if [ "$pkg" = "all" ]; then
  pkgfiles="$(cd $devdatadir/apks; ls *.apk)"
  for file in $pkgfiles; do
    pkgs="$pkgs ${file%\.apk}"
  done
fi

echo "Restoring backup for uid $uid.."
for pkg in $pkgs; do
  [ -z "$pkg" ] && ( echo "Missing pkg"; exit 1)
  echo "  Restoring pkg $pkg.."
  [ -f "$base/apks/$pkg.apk" ] && (
    echo "    Installing pkg.."
    if [ -z "$(pm list package $pkg)" ]; then
      pm install $base/apks/$pkg.apk
      for user in $(cd /data/user; ls | grep '^[0-9]*$' | grep -v $uid); do
        pm disable --user $user $pkg
      done
    else
      pm enable --user $uid $pkg
    fi
    echo "    done."
  )
  [ -f "$base/data/$uid/$pkg-user.tar" ] && (
    echo "    Getting uid/gid and secontext.."
    secontext=$(ls -dZ user/$uid/$pkg | cut -f1 -d' ')
    user=$(ls -dl user/$uid/$pkg | cut -f3 -d' ')
    group=$(ls -dl user/$uid/$pkg | cut -f4 -d' ')
    echo "    done."
    echo "    Restoring userdata.."
    rm -rf user/$uid/$pkg
    tar x -C user/$uid -f $base/data/$uid/$pkg-user.tar $pkg
    echo "    done."
    echo "    Restoring ownership.."
    chown -R $user:$group user/$uid/$pkg
    echo "    done."
    echo "    Restoring secontext.."
    find user/$uid/$pkg -exec chcon $secontext {} \;
    echo "    done."
  )
  [ -f "$base/data/$uid/$pkg-media.tar" ] && (
    echo "    Restoring media.."
    rm -rf media/$uid/Android/data/$pkg
    tar x -C media/$uid/Android/data -f $base/data/$uid/$pkg-media.tar $pkg
    echo "    done."
  )
  echo "  done."
done
echo "done."
