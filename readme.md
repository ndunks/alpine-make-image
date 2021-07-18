# Build Alpine Image

Based From: https://github.com/alpinelinux/alpine-make-vm-image

- Hybrid Partition MBR & GPT 
- dual bootloader mode BIOS & UEFI supported using syslinux

## for Qemu / Virtual
``` bash
# Make build/alpine.qcow
make virt

# Emulate using Qemu BIOS Boot
make virt-start

# Qemu UEFI Boot
make virt-start-uefi
```

## for PC / LTS
``` bash
# Make build/alpine.img
make lts

# Emulate using Qemu BIOS Boot
make lts-start

# Qemu UEFI Boot
make lts-start-uefi
```

## Writing to Real Media

``` bash
sudo dd bs=4M conv=notrunc status=progress if=build/alpine.img of=/dev/sdX

```

**Resize root partition**
``` bash
sudo gdisk /dev/sdX
r # Recovery & transform
e # Rebuild backup
w # Write changes

sudo parted /dev/sdX resizepart 2 4GB
```