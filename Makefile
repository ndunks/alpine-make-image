
ALPINE_VERSION := 3.13
BUILD_ARGS := --no-cleanup-temp --image-size 1200M  -b ${ALPINE_VERSION}


all: build

virt: build/alpine.qcow2

build/alpine.qcow2: setup/_setup.sh
	sudo ./alpine-make-vm-image --serial-console ${BUILD_ARGS} -k virt \
	--script-chroot -f qcow2 build/alpine.qcow2 setup/_setup.sh

virt-start: virt
	sudo qemu-system-x86_64 -enable-kvm -smp 3 -m 512M -serial mon:stdio \
    -drive if=virtio,id=disk,file=build/alpine.qcow2,format=qcow2

virt-start-uefi: virt
	sudo qemu-system-x86_64 -enable-kvm -smp 3 -m 512M -serial mon:stdio -bios /usr/share/ovmf/OVMF.fd \
    -drive if=virtio,id=disk,file=build/alpine.qcow2,format=qcow2

lts: build/alpine.img

build/alpine.img: setup/_setup.sh
	sudo ./alpine-make-vm-image ${BUILD_ARGS} -k lts -i "scsi virtio ata usb" \
	--script-chroot -f raw build/alpine.img setup/_setup.sh

lts-start: lts
	sudo qemu-system-x86_64 -enable-kvm -smp 3 -m 512M \
    -drive if=virtio,id=disk,file=build/alpine.img,format=raw

lts-start-uefi: virt
	sudo qemu-system-x86_64 -enable-kvm -smp 3 -m 512M -bios /usr/share/ovmf/OVMF.fd \
    -drive if=virtio,id=disk,file=build/alpine.img,format=raw

clean:
	rm -rf build/alpine.*

.PHONY: all virt virt-start virt-start-uefi lts lts-start lts-start-uefi clean