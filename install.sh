#!/bin/bash

dia=$(date +%d-%m-%Y)
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)

vrf_error () {
  if [ $? -ne 0]; then
    echo
    echo "erro ao efetuar esta operacao"
    echo "processo cancelado"
    exit 1
  fi
}

rollback () {
  rm -rf /opt/*
  tar xfz /var/backups/node.${dia}.tar.gz -C /opt

# verifica root
if [ $(id -u) -ne 0 ]; then
  echo "voce precisa ser root para continuar"
  exit 1
fi

# verifica a versao do sistema operacional
if [ $(lsb_release -r | awk -F" " '{ print $2 }') != "16.04" ]; then
  echo "sistema homologado para a versao: ubuntu 16.04 LTS"
  echo "processo cancelado"
  exit 1
fi

# verifica numero de cpus
echo "verificando numero de cpus"
if [ $cpus -lt 1 ] || [ $cpus -gt 32 ]; then
  echo "este servidor nao obedece aos requisitos desta aplicacao"
  echo "minimo permitido: 1 cpu"
  echo "maximo permitido: 32 cpus"
  echo "processo cancelado"
  exit 1
else
  echo "total de cpus: ${cpus}"
fi

# verifica conexao com a internet
echo "verificando conexao com a internet"
ping -c 2 8.8.8.8 2> /dev/null
vrf_error

# iniciando procedimento
echo "iniciando deploy..."

# verificando estrutura de pasta
echo "verificando estrutura de pastas"
if [ -d /opt/node_modules/ ]; then
  echo "criando backup do ambiente atual"
  tar cfz /var/backups/node.${dia}.tar.gz /opt
  vrf_error
  echo "arquivo de backup gerado em: /var/backups"
fi

# desabilitando ipv6
grep "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf 2> /dev/null
if [ $? -ne 0 ]; then
  echo "desabilitando ipv6"
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  sysctl -p > /dev/null
  vrf_error
fi

# instalacao do nginx para criacao de redirecionamento
echo "instalando servidor web"
apt-get install -y nginx 2> /dev/null
cp default /etc/nginx/sites-available/default
cp cert.crt /etc/ssl/private/cert.crt
cp cert.key /etc/ssl/private/cert.key
vrf_error

# instalacao do node.js
echo "baixando servidor node.js"
wget https://nodejs.org/dist/v4.4.7/node-v4.4.7-linux-x64.tar.xz 2> /dev/null
vrf_error
echo "extraindo conteudo"
tar xfJ node-v4.4.7-linux-x64.tar.xz -C /opt/node-v4.4.7-linux-x64.tar.xz 2> /dev/null
ln -s /opt/node-v4.4.7-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
ln -s /opt/node-v4.4.7-linux-x64/bin/node /usr/bin/node
vrf_error

# instalacao das dependencias usando o npm
echo "instalando as dependencias do npm"
cd /opt/
echo "instalando express"
npm install express --save 2> /dev/null
vrf_error
echo "instalando pm2"
npm install pm2 -g
ln -s /opt/node_modules/pm2/bin/pm2 /usr/bin/pm2
pm2 completion install > /dev/null
pm2 logrotate > /dev/null
vrf_error

# copiando arquivo da aplicacao
echo "copiando aplicacao do node para o sistema"
cp app.js /opt/app.js
vrf_error

# reiniciando o nginx
echo "reiniciando o servidor web"
systemctl restart nginx
vrf_error

# sistema de verificacao de servico ativo
echo "criando monitoramento da aplicacao a cada 5 segundos"
mkdir /agendamentos
cp reboot_services.sh /agendamentos/
chmod u+x /agendamentos/reboot_services.sh
echo "* * * * * sleep 5 && /agendamentos/reboot_services.sh" >> /var/spool/cron/crontabs/root

# iniciando a app
echo "iniciando a aplicacao em modo cluster e balanceamento de carga"
pm2 start /opt/app.js -i 0
vrf_error

# ajuda
echo "ajuda:"
echo
echo "digite: pm2 list # para listar sua aplicacao em execucao"
echo "digite: pm2 kill # para interromper toda a aplicacao"
echo "digite: pm2 monit # para ver o consumo de memoria e processamento da aplicacao"
echo "digite: pm2 describe <id da aplicacao> # mostra informacoes sobre a aplicacao"
echo "digite: pm2 gracefulReload all # para reiniciar a aplicacao em modo seguro"
echo
echo "para maiores informacoes consulte: http://pm2.keymetrics.io/docs/usage/quick-start/"
echo
echo "logs:"
echo
echo "consulte: /root/.pm2/logs"
echo
echo "obrigado!"

exit 0 
