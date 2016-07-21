#!/bin/bash

# arquivo de log
log="$(date +%d%m%Y)-install.log"

# verifica root
if [ $(id -u) -ne 0 ]; then
  echo "voce precisa ser root para continuar"
  exit 1
fi

# verificando a versao do sistema operacional
if [ $(lsb_release -r | awk -F" " '{ print $2 }') != "16.04" ]; then
  echo "esse sistema roda na versao Ubuntu Server 16.04 LTS"
  echo "por favor, corriga sua versao e tente novamente"
  echo "processo interrompido"
  exit 1
fi 

# boas vindas
echo "bem-vindo ao sistema de deploy do ambiente node.js"
echo "para maiores informacoes consulte o arquivo de log gerado durante o processo de deploy"
echo

# iniciando procedimento
echo "iniciando o processo de deploy..."

# desabilitando ipv6
echo "desabilitando ipv6 para evitar conflitos"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

# instalacao dos pacotes do docker
echo "instalando docker e suas dependencias"
apt-get update >> $log
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D >> $log
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | tee /etc/apt/sources.list.d/docker.list >> $log
apt-get update >> $log
apt-get install -y docker-engine >> $log
