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

cd /data
pkgs="$*"
uids=$uid

# Backup all installed packages?
if [ "$pkg" = "all" ]; then
  pkgfiles="$(cd $devdatadir/apks; ls *.apk)"
  pkgs=""
  for file in $pkgfiles; do
    pkgs="$pkgs ${file%\.apk}"
  done
fi

if [ "$uid" = "all" ]; then
  uids="$(cd $devdatadir/data; ls | grep '^[0-9]*$')"
fi

for uid in $uids; do
  echo "Restoring backup for uid $uid.."
  for pkg in $pkgs; do
    [ -z "$pkg" ] && ( echo "Missing pkg"; exit 1)
    echo "  Restoring pkg $pkg.."
    if [ -f "$base/apks/$pkg.apk" ]; then
      if [ -z "$(pm list package $pkg)" ]; then
        echo "    Installing pkg.."
        pm install $base/apks/$pkg.apk >/dev/null
        echo "    done."
      else
        echo "    pkg already installed.."
      fi
      if [ -f "$base/data/$uid/$pkg.disabled" ]; then
        echo "    Disabling pkg.."
        pm disable --user $uid $pkg >/dev/null
        echo "    done."
      else
        echo "    Enabling pkg.."
        pm enable --user $uid $pkg >/dev/null
        echo "    done."
      fi
    fi
    if [ -f "$base/data/$uid/$pkg-user.tar" ]; then
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
    fi
    if [ -f "$base/data/$uid/$pkg-media.tar" ]; then
      echo "    Restoring media.."
      rm -rf media/$uid/Android/data/$pkg
      tar x -C media/$uid/Android/data -f $base/data/$uid/$pkg-media.tar $pkg
      echo "    done."
    fi
    echo "  done."
  done
  echo "done."
done
