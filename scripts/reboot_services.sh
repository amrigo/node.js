#!/bin/bash

# reinicia o servidor web
pidof nginx > /dev/null
if [ $? -ne 0 ]; then
  /etc/init.d/nginx stop
  /etc/init.d/nginx start
fi

# reinicia o servidor node
pidof app.js > /dev/null
if [ $? -ne 0 ]; then
  pm2 -f start /opt/app.js -i 0
fi
