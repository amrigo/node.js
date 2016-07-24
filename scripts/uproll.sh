#!/bin/bash

# uso: ./uproll.sh <nome do modulo>

dia=$(date +%d-%m-%Y)

function backup() {
  if [ -d /opt/node_modules ]; then
    tar cfz /var/backups/node.backup.${dia}.tar.gz /opt
    if [ $? -ne 0 ]; then
      echo "erro ao realizar procedimento de backup"
      echo "update nao pode ser realizado"
      echo "processo cancelado"
      exit 1
    else
      echo "backup realizado com sucesso!"
      echo "local de backup: /var/backups/"
    fi
  fi
}

function rollback() {
  if [ -f /var/backups/node.backup.${dia}.tar.gz ]; then
    tar xfz /var/backups/node.backup.${dia}.tar.gz -C /
    if [ $? -ne 0 ]; then
      echo "falha no rollback"
      exit 1
    else
      echo "rollback realizado com sucesso"
    fi
  fi
}

if [ "$1" == " " ]; then
  echo "voce precisa digitar um pacote para instalar ou atualziar"
  echo "exemplo: ./uproll.sh <nome_do_pacote>"
  exit 1
fi

if [ -d /opt/node_modules/$1 ]; then
  backup
  cd /opt
  echo "atualizando pacote $1"
  npm update $1 > /dev/null && pidof app.js > /dev/null
  if [ $? -eq 0 ]; then
    echo "modulo $1 atualizado com sucesso!"
  else
    rollback
  fi
else
  backup
  cd /opt
  echo "instalando pacote $1"
  npm install $1 > /dev/null && pidof app.js > /dev/null
  if [ $? -eq 0 ]; then
    echo "modulo $1 instalado com sucesso!"
  else
    npm uninstall $1
    rm -rf /opt/node_modules/$1
    echo "erro ao instalar pacote, pacote deletado"
  fi
fi
