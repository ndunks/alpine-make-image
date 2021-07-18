#!/bin/sh

if [ -z "$KERNEL_FLAVOR" ]; then
    echo "NO MODE"
    exit 1
fi

setup-timezone -z Asia/Jakarta

if [ $KERNEL_FLAVOR != "virt" ]; then
    step "Installing firmwares for laptop"
    # apk add linux-firmware-intel linux-firmware-i915 \
    # 	linux-firmware-ath9k_htc linux-firmware-ath10k \
    # 	linux-firmware-ath11k wpa_supplicant
    apk add linux-firmware-ath9k_htc linux-firmware-rtl_nic
fi;

step 'Install tools'
apk add bind-tools usbutils curl nano python3 \
    openssh-server minicom htop sudo rsync wpa_supplicant

step 'Configuring User'
adduser --disabled-password -s /bin/sh $USERNAME
adduser $USERNAME audio
adduser $USERNAME video
adduser $USERNAME dialout
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Unlock user to able to login via SSH
sed -i "s/^$USERNAME:!/$USERNAME:*/" /etc/shadow

mkdir ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMWYKYtc0wjTYJJ28lwYAb0fgginP\
DM9J6z2WjZQpI1M+L9Ip01ZDohGyYaqYRq/0DGNTJy6K8Ejm7WgkUxnp2K3NCq22e77jzmCbO\
EkWWsaVtekwdjkUkWZhfpYhQlkmswFc3NrYuXEQO+npqP2wG45XUMdOSUZovY1dPBTW3O0rl0\
tiEt7JYB3Cf1edcyWamtHOer+4zfCg5cBqYutk6SeGm5Pn4z7h4yvhyvpxOnbGhc8mFswJGMh\
w8+RYzi/7cfc76op2JKY979mg+XNnH1f7vEJ539qf0eruozUhMRZ7Zc5+sIhIOALQGFrqbk/c\
S/k58bdBa4Mvrg+mhXLu7 ndunks@debian" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

mkdir /home/$USERNAME/.ssh
cp ~/.ssh/authorized_keys /home/$USERNAME/.ssh/
chmod 600 /home/$USERNAME/.ssh/authorized_keys
sed -E -i "s/^(X11Forwarding\s+).*/\1yes/" /etc/ssh/sshd_config

# auto login user on tty1, remove other tty
sed -E -i \
    -e "s/^(tty1:.*):\/.*/\1:\/bin\/login -f $USERNAME/" \
    -e "s/^(tty[2-6])/# \1/" \
    /etc/inittab

if [ $KERNEL_FLAVOR = "virt" ]; then
    step "Enabling ttyS0"
    sed -E -i \
     -e "s/^(ttyS0:.*):\/.*/\1:\/bin\/login -f root/" \
    /etc/inittab
fi

step "Configuring System"

cat <<EOF > /etc/motd
Alpine Linux
EOF

sed -E -i \
    -e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
    -e 's/^[# ](rc_logger)=.*/\1=YES/' \
    -e 's/^[# ](unicode)=.*/\1=YES/' \
    /etc/rc.conf

step 'Setup Networking'

if [ $KERNEL_FLAVOR = "virt" ]; then
    cat > /etc/network/interfaces <<-EOF
        auto  lo
        iface lo inet loopback
        auto  eth0
        iface eth0 inet dhcp
EOF
    ln -s networking /etc/init.d/net.eth0
    rc-update add net.eth0 default
else
    cat > /etc/network/interfaces <<-EOF
    auto  lo
    iface lo inet loopback
    auto  wlan0
    iface wlan0 inet dhcp
EOF
    ln -s networking /etc/init.d/net.wlan0
    rc-update add net.wlan0 default
    # Again, no CMOS in my dev server, so no hwclock
    rc-update del hwclock boot

    wpa_passphrase 'pembangunan' 'oranganggo' > /etc/wpa_supplicant/wpa_supplicant.conf
    chmod 0777 /etc/wpa_supplicant/wpa_supplicant.conf
    rc-update add wpa_supplicant boot
fi

ln -s networking /etc/init.d/net.lo
step 'Enabling services'
rc-update add net.lo boot
#rc-update add termencoding boot
rc-update add sshd default
rc-update add acpid default
#rc-update add crond default
