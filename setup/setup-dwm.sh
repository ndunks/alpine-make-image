#!/bin/sh

# https://wiki.alpinelinux.org/wiki/Dwm
step "Setup DWM"
mkdir -p /run/openrc/
touch /run/openrc/softlevel

if [ $KERNEL_FLAVOR = "virt" ]; then
    setup-xorg-base dbus xf86-video-modesetting setxkbmap kbd xrandr xset xsetroot \
        || echo 'Some fail in chroot'
else
    setup-xorg-base dbus mesa-egl xf86-video-intel\
        xf86-video-fbdev xf86-video-vesa xf86-input-mouse \
        xf86-input-keyboard setxkbmap kbd xrandr xset xsetroot \
        || echo 'Some fail in chroot'
fi

step "Installing Fonts"
# still in edge testing branch: ttf-anonymous-pro
apk add --no-scripts fontconfig
apk add ttf-opensans ttf-opensans ttf-hack ttf-ubuntu-font-family
apk add git make gcc g++ libx11-dev libxft-dev libxinerama-dev ncurses 

cd /tmp
git clone --single-branch --depth=1  https://git.suckless.org/dwm
cd dwm
curl https://dwm.suckless.org/patches/centeredmaster/dwm-centeredmaster-6.1.diff | git apply -
make clean install

# cd /tmp
# git clone --single-branch --depth=1  https://git.suckless.org/dmenu
# cd dmenu && make clean install

cd /tmp
git clone --single-branch --depth=1  https://git.suckless.org/st
cd st && make clean install

cd /
echo exec dwm > /home/$USERNAME/.xinitrc

cat <<EOF > /home/$USERNAME/.profile
#!/bin/sh
alias getdisplay="grep DISPLAY= /proc/\\\$(pidof -s dwm)/environ 2> /dev/null | cut -d = -f2"
alias wake="xset dpms force on"

if [ "\$SHLVL" = "1" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    # Invoked in login
    startx 2>&1 > /dev/null &
    while true; do
        sleep 0.1
        DISPLAY=\$(getdisplay)
        [[ -z "\$DISPLAY" ]] || break
    done
    export DISPLAY
    if [ -x .autorun ]; then
        . .autorun
    fi
elif [ -z "\$DISPLAY" ]; then
    # May in SSH Shell
    export DISPLAY=\$(getdisplay)
fi
EOF

cat <<EOF > /home/$USERNAME/.autorun
#!/bin/sh
# This script called once when starting X Display

# Disable sleep 
#xset -dpms
# long sleep
xset dpms 1800 1800 1800

DWM_STATUS="Alpine \$(ip a s wlan0 | grep -o '\d\+\.\d\+\.\d\+\.\d\+')"
xsetroot -name "\$DWM_STATUS"

# Wait online
while ! ping -q -c 1 -W 1 1.1.1.1 > /dev/null; do
    logger "$USER: Wait online.."
    sleep 1
done
EOF

chmod +x /home/$USERNAME/.autorun
chown $USERNAME:$USERNAME /home/$USERNAME/.*

# Give root ability to use X Display
cat <<EOF >> /root/.profile
alias wake=xset dpms force on
export XAUTHORITY=/home/$USERNAME/.Xauthority
export DISPLAY=:0
EOF
