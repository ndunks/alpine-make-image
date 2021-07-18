# Build Alpine Image

Based From: https://github.com/alpinelinux/alpine-make-vm-image

- Hybrid Partition MBR & GPT 
- dual bootloader mode BIOS & UEFI supported using syslinux


## for Qemu / Virtual
```
make virt
# Qemu BIOS Boot
make virt-start
# Qemu UEFI Boot
make virt-start-uefi
```

## for PC / Laptop
```
make pc
# Qemu BIOS Boot
make pc-start
# Qemu UEFI Boot
make pc-start-uefi
```
