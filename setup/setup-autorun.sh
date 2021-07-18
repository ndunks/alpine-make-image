#!/bin/sh
cat <<EOF >> /home/$USERNAME/.autorun
st htop &
# exec chromium-browser "$url" --window-position=0,0 \
#     --kiosk \
#     --no-sandbox \
#     --full-screen \
#     --noerrdialogs \
#     --disable-translate \
#     --no-first-run \
#     --fast \
#     --fast-start \
#     --ignore-gpu-blacklist \
#     --disable-quic \
#     --enable-fast-unload \
#     --enable-tcp-fast-open \
#     ---enable-native-gpu-memory-buffers \
#     --enable-gpu-rasterization \
#     --enable-zero-copy \
#     --disable-features=TranslateUI

EOF

