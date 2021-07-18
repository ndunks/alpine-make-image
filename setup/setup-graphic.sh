#!/bin/sh

step 'Setup Graphical'
setup-xorg-base xterm dbus xf86-video-intel mesa-egl \
    xf86-video-fbdev xf86-video-vesa xf86-input-mouse \
    xf86-input-keyboard setxkbmap kbd xrandr xset chromium

rc-update add dbus default

cat <<EOF > .profile
#!/bin/sh

[ "\$(tty)" = "/dev/tty1" ] && exec startx 2>&1 > /dev/null
EOF

cat <<EOF > .xinitrc
#!/bin/sh

# turn off screensaver
# xset -dpms
# xset s off
# xset s noblank

# screen size
# width="1920"
# height="1080"

url="about:home"
# exec chromium-browser $url --window-size=$width,$height --window-position=0,0 --kiosk --no-sandbox --full-screen --incognito --noerrdialogs --disable-translate --no-first-run --fast --fast-start --ignore-gpu-blacklist --disable-quic --enable-fast-unload --enable-tcp-fast-open ---enable-native-gpu-memory-buffers --enable-gpu-rasterization --enable-zero-copy --disable-infobars --disable-features=TranslateUI --disk-cache-dir=/tmp
exec chromium-browser "$url" --window-position=0,0 \
    --kiosk \
    --no-sandbox \
    --full-screen \
    --noerrdialogs \
    --disable-translate \
    --no-first-run \
    --fast \
    --fast-start \
    --ignore-gpu-blacklist \
    --disable-quic \
    --enable-fast-unload \
    --enable-tcp-fast-open \
    ---enable-native-gpu-memory-buffers \
    --enable-gpu-rasterization \
    --enable-zero-copy \
    --disable-features=TranslateUI
EOF
