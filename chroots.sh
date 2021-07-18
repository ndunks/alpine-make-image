#!/bin/bash
set -e

[ "$(id -u)" != "0" ] && echo "Run as root" && exit 1
# [ -z "$1" ] && echo "No root path" && exit 1

image=$PWD/build/alpine.qcow2
CH_ROOT=${1:-/tmp/alpine-qcow2}
CH_ROOT=${CH_ROOT%/}

get_available_nbd() {
	local dev; for dev in $(find /dev -maxdepth 2 -name 'nbd[0-9]*'); do
		if [ "$(blockdev --getsize64 "$dev")" -eq 0 ]; then
			echo "$dev"; return 0
		fi
	done
	return 1
}
AUTOMOUNT=''
automount() {
	echo "Mounting $image at $CH_ROOT"
	[ -f $image ] || ( echo "Not found $image" && exit 1 )
	
	AUTOMOUNT=$(get_available_nbd) || {
		modprobe nbd max_part=2
		sleep 1
		AUTOMOUNT=$(get_available_nbd)
	} || die 'No available nbd device found!'

	qemu-nbd --connect="$AUTOMOUNT" --cache=writeback --format=qcow2 "$image"
	partprobe $AUTOMOUNT
	mkdir -p $CH_ROOT
	mount "${AUTOMOUNT}p2" "$CH_ROOT"
	mount "${AUTOMOUNT}p1" "$CH_ROOT/boot"
	export AUTOMOUNT
}

# Binds the directory $1 at the mountpoint $2 and sets propagation to private.
mount_bind() {
	mkdir -p "$2"
	mount --bind "$1" "$2"
	mount --make-private "$2"
}

# Prepares chroot at the specified path.
prepare_chroot() {
    
	mkdir -p $CH_ROOT/proc
	mount -t proc none $CH_ROOT/proc
	mount_bind /dev $CH_ROOT/dev
	mount_bind /sys $CH_ROOT/sys

	install -D -m 644 /etc/resolv.conf $CH_ROOT/etc/resolv.conf
}

cleanup() {
    set +eu
	trap '' EXIT HUP INT TERM  # unset trap to avoid loop
    echo "Cleanup $CH_ROOT"
	cat /proc/mounts | cut -d ' ' -f 2 | grep "^$CH_ROOT/" | sort -r | xargs umount
	if [ "$AUTOMOUNT" ]; then
		umount $CH_ROOT
		echo "Disconnect $AUTOMOUNT"
		qemu-nbd --disconnect "$AUTOMOUNT" \
			|| echo "Failed to disconnect $AUTOMOUNT; disconnect it manually"
	fi
}

if ! grep "$CH_ROOT" /proc/mounts; then
	automount
fi

trap cleanup EXIT HUP INT TERM

prepare_chroot

chroot "$CH_ROOT" /bin/login -f root
