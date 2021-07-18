#!/bin/bash

[ -d build ] || mkdir build
#
grep -q $PWD/build /proc/mounts || sudo mount -t tmpfs tmpfs $PWD/build

# using apt-cacher for fast develop
# Add config: /etc/apt-cacher-ng/acng.conf
# VfilePatternEx: (metalink\?repo=[0-9a-zA-Z-]+&arch=[0-9a-zA-Z_-]+|/\?release=[0-9]+&arch=|repodata/.*\.(xml|sqlite)\.(gz|bz2)|APKINDEX.tar.gz|filelists\.xml\.gz|filelists\.sqlite\.bz2|repomd\.xml|packages\.[a-zA-Z][a-zA-Z]\.gz)
# PfilePatternEx: (/dists/.*/by-hash/.*|\.tgz|\.tar|\.xz|\.bz2|\.rpm|\.apk)$
grep -q /ext4 /proc/mounts || sudo mount $(grep /ext4 /etc/fstab | cut -d ' ' -f1)
pidof apt-cacher-ng || sudo systemctl start apt-cacher-ng
