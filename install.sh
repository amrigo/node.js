#!/bin/bash

dia=$(date +%d-%m-%Y)
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)

vrf_error () {
  if [ $? -ne 0]; then
    echo
    echo "erro ao efetuar esta operacao"
    echo "verfique o problema e tente novamente"
    echo "processo cancelado"
    exit 1
  fi
}

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
echo

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
echo "copiando arquivos de configuracao"
cp web/default /etc/nginx/sites-available/default && \
cp private/cert.crt /etc/ssl/private/cert.crt && \
cp private/cert.key /etc/ssl/private/cert.key
vrf_error

# instalacao do node.js
echo "baixando servidor node.js"
wget -O /opt/node-v4.4.7-linux-x64.tar.xz https://nodejs.org/dist/v4.4.7/node-v4.4.7-linux-x64.tar.xz 2> /dev/null
vrf_error
echo "instalando aplicacao"
tar xfJ /opt/node-v4.4.7-linux-x64.tar.xz -C /opt/ 2> /dev/null
vrf_error
echo "criando links da aplicacao"
ln -s /opt/node-v4.4.7-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm && \
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
vrf_error
echo "criando link da aplicacao"
ln -s /opt/node_modules/pm2/bin/pm2 /usr/bin/pm2
vrf_error
echo "instalando modulo do pm2"
pm2 completion install > /dev/null
vrf_error
echo "criando rotatividade de logs"
pm2 logrotate > /dev/null
vrf_error

# copiando arquivo da aplicacao
echo "copiando aplicacao do node para o sistema"
cp apps/app.js /opt/app.js
vrf_error

# reiniciando o nginx
echo "reiniciando o servidor web"
systemctl restart nginx
vrf_error

# criando pasta de agendamentos
if [ ! -d /agendamentos ]; then
  mkdir /agendamentos
fi

# sistema de verificacao de servico ativo
echo "criando monitoramento da aplicacao a cada 5 segundos"
cp scripts/reboot_services.sh /agendamentos/ && \
chmod u+x /agendamentos/reboot_services.sh && \
echo "* * * * * sleep 5 && /agendamentos/reboot_services.sh" >> /var/spool/cron/crontabs/root
vrf_error

# sistema de verificacao de acesso ao servidor web
echo "criando monitoramento de acesso ao servidor web"
cp scripts/frequencia_web.sh /agendamentos/ && \
chmod u+x /agendamentos/frequencia_web.sh && \
echo "59 23 * * * /agendamentos/frequencia_web.sh" >> /var/spool/cron/crontabs/root
vrf_error

# iniciando a app
echo "iniciando a aplicacao node.js"
pm2 start /opt/app.js -i 0
vrf_error

echo "procedimento concluido com sucesso!"

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
