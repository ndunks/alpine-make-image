#!/bin/sh

step "Clearing setup files"
sed -i 's/localhost:3142\///' /etc/apk/repositories
# Use apt-cacher-ng inside qemu
# sed -i 's/\/\//\/\/10.0.2.2:3142\//' /etc/apk/repositories
# sed -E -i 's/\d+\.\d+\.\d+\.\d+:3142/10.0.2.2:3142/' /etc/apk/repositories


step "Fixing permissions"
cd /home/$USERNAME
chown -R $USERNAME:$USERNAME .
( [ -f .profile ] && chmod +x .profile ) || true
( [ -f .xinitrc ] && chmod +x .xinitrc ) || true
