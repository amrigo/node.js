#!/bin/bash

cpus=$(cat /proc/cpuinfo | grep processor | wc -l)

# verifica root
if [ $(id -u) -ne 0 ]; then
  echo "Voce precisa ser root para continuar"
  exit 1
fi

# verificando a versao do sistema operacional
if [ $(lsb_release -r | awk -F" " '{ print $2 }') != "16.04" ]; then
  echo "Sistema homologado para a versao: Ubuntu 16.04 LTS"
  echo "Processo interrompido"
  exit 1
fi

# boas vindas
echo
echo "Bem-vindo ao sistema de deploy do ambiente Node.js"
echo

# iniciando procedimento
echo "Iniciando o processo de deploy..."
echo

# desabilitando ipv6
grep "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf > /dev/null
if [ $? -ne 0 ]; then
  echo "Desabilitando ipv6 para evitar conflitos"
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  sysctl -p > /dev/null
fi

# instalacao do nginx para criacao de redirecionamento
echo "instalando nginx"
apt-get install -y nginx
cp default /etc/nginx/sites-available/default
cp cert.crt /etc/ssl/private/cert.crt
cp cert.key /etc/ssl/private/cert.key

# instalacao do node.js
wget https://nodejs.org/dist/v4.4.7/node-v4.4.7-linux-x64.tar.xz
tar xvfJ node-v4.4.7-linux-x64.tar.xz -C /opt/node-v4.4.7-linux-x64.tar.xz
ln -s /opt/node-v4.4.7-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
ln -s /opt/node-v4.4.7-linux-x64/bin/node /usr/bin/node

# instalacao das dependencias usando o npm
echo "instalacao das dependencias do npm"
cd /opt/
npm install express --save
npm install pm2 -g
ln -s /opt/node_modules/pm2/bin/pm2 /usr/bin/pm2
pm2 startup

# copiando arquivo da aplicacao
echo "copiando app do node para o sistema"
cp app.js /opt/app.js

# reiniciando o nginx
systemctl restart nginx

# iniciando a app
if [ $cpus -gt 0 ] || [ $cpus -le 32 ]; then
  pm2 start /opt/app.js -i 0
else
  pm2 start /opt/app.js -i $cpus
fi
