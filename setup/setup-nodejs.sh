#!/bin/bash

NODE_HOME=/node
step "Installing NodeJS to $NODE_HOME"
apk add nodejs yarn
mkdir -m 0776 $NODE_HOME
addgroup -S node
addgroup $USERNAME node

cat <<EOF > /etc/profile.d/node.sh
export PATH="\$PATH:$NODE_HOME/bin"
export NODE_HOME="$NODE_HOME"
export NPM_CONFIG_PREFIX="$NODE_HOME"
EOF
chmod +x /etc/profile.d/node.sh

. /etc/profile.d/node.sh

yarn config set registry https://registry.npmjs.com -g
yarn config set prefix $NODE_HOME -g
yarn config set global-folder $NODE_HOME -g
yarn config set cache-folder $NODE_HOME/cache -g

yarn global add node-gyp pm2
chown -R root:node $NODE_HOME
chmod -R g+w $NODE_HOME
