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

# instalacao das atualizacoes do sistema
echo "verificando se o seu sistema esta atualizado..."
apt-get update  >> $log
apt-get upgrade -y >> $log
if [ $? -ne 0 ]; then
  echo "erro ao instalar atualizacoes"
  echo "processo interrompido"
  echo "consulte o arquivo de log para maiores informacoes"
  exit 1
fi


