#!/bin/bash

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

# instalacao dos pacotes do docker
echo "Instalando docker e suas dependencias"
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" >> /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine

# criando imagem usando o Dockerfile
echo "Criando imagem do app node.js"
docker build -t node.js/node-app .

# iniciando a aplicacao node.js
docker run -p 3000:3000 -d node.js/node-app
