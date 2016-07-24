#!/bin/bash

dia=$(date +%d-%m-%Y)
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)

# verifica root
if [ $(id -u) -ne 0 ]; then
  echo "voce precisa ser root para continuar"
  exit 1
fi

echo
echo "########################################################"
echo "##########    Sistema de deploy do Node.JS    ##########"
echo "########################################################"
echo
echo "Bem-vindo ao sistema de deploy do Servidor Node.JS" 
echo

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
ping -q -c 2 8.8.8.8 > /dev/null
if [ $? -ne 0 ]; then
  echo "erro de conexao com a internet"
  echo "processo cancelado"
  exit 1
fi

# iniciando procedimento
echo
echo "iniciando deploy..."
echo

# desabilitando ipv6
grep "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf > /dev/null
if [ $? -ne 0 ]; then
  echo "desabilitando ipv6"
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  sysctl -p > /dev/null
  if [ $? -ne 0 ]; then
    echo "erro ao desabilitar conexao ipv6"
    echo "processo cancelado"
    exit 1
  fi
fi

# instalacao do nginx para criacao de redirecionamento
echo "instalando servidor web"
apt-get install -y nginx -q > /dev/null && \
echo "copiando arquivos de configuracao" && \
cp ./web/default /etc/nginx/sites-available/default > /dev/null && \
cp ./private/cert.crt /etc/ssl/private/cert.crt > /dev/null && \
cp ./private/cert.key /etc/ssl/private/cert.key > /dev/null
if [ $? -ne 0 ]; then
  echo "erro na instalacao do servidor web"
  echo "processo cancelado"
  exit 1
fi

# instalando benchmarking throghput
apt-get install siege -y -q > /dev/null
if [ $? -ne 0 ]; then
  echo "erro na instalacao do servico de benchmarking"
  echo "processo cancelado"
  exit 1
fi

# instalando servico de email
echo "instalando servico de email"
apt-get install -y mailutils
if [ $? -ne 0 ]; then
  echo "erro na instalacao do servico de email"
  echo "processo cancelado"
  exit 1
fi

# instalacao do node.js
echo "baixando servidor node.js"
wget -q -O /opt/node-v4.4.7-linux-x64.tar.xz https://nodejs.org/dist/v4.4.7/node-v4.4.7-linux-x64.tar.xz > /dev/null
if [ $? -ne 0 ]; then
  echo "erro no download do servidor node.js"
  echo "processo cancelado"
  exit 1
fi
echo "instalando aplicacao"
tar xfJ /opt/node-v4.4.7-linux-x64.tar.xz -C /opt/ > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao instalar aplicacao node.js"
  echo "processo cancelado"
  exit 1
fi
echo "criando links da aplicacao"
ln -sf /opt/node-v4.4.7-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm > /dev/null && \
ln -sf /opt/node-v4.4.7-linux-x64/bin/node /usr/bin/node > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao criar link da aplicacao node"
  echo "processo cancelado"
  exit 1
fi

# copiando arquivo da aplicacao
echo "copiando aplicacao do node para o sistema"
cp ./apps/app.js /opt/app.js > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao copiar aplicacao node.js"
  echo "processo cancelado"
  exit 1
fi

# criando pasta de agendamentos
if [ ! -d /agendamentos ]; then
  mkdir /agendamentos
fi

# copiando arquivo de throughput
echo "copiando arquivo de throughput"
cp ./scripts/throughput.sh /agendamentos/ > /dev/null && \
chmod u+x /agendamentos/throughput.sh
if [ $? -ne 0 ]; then
  echo "erro ao copiar arquivo de throughput"
  echo "processo cancelado"
  exit 1
fi

# sistema de verificacao de servico ativo
echo "criando monitoramento da aplicacao"
cp ./scripts/reboot_services.sh /agendamentos/ > /dev/null && \
chmod u+x /agendamentos/reboot_services.sh > /dev/null && \
echo "*/1 * * * * root /agendamentos/reboot_services.sh" >> /etc/crontab
if [ $? -ne 0 ]; then
  echo "erro ao criar servico de monitoramento"
  echo "processo cancelado"
  exit 1
fi

# sistema de verificacao de acesso ao servidor web
echo "criando monitoramento de acesso ao servidor web"
if [ ! -d /relatorios ]; then
  mkdir /relatorios
  if [ $? -ne 0 ]; then
    echo "erro ao criar diretorio de relatorios"
    echo "processo cancelado"
    exit 1
  fi
fi
cp ./scripts/frequencia_web.sh /agendamentos/ > /dev/null && \
chmod u+x /agendamentos/frequencia_web.sh > /dev/null && \
echo "59 23 * * * root /agendamentos/frequencia_web.sh" >> /etc/crontab
if [ $? -ne 0 ]; then
  echo "erro ao criar servico de verificacao de acesso ao servidor web"
  echo "processo cancelado"
  exit 1
fi

# copiando arquivo de deploy e rollback
cp ./scripts/uproll.sh /agendamentos/ > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao copiar arquivo"
  echo "processo cancelado"
  exit 1
fi

# instalacao das dependencias usando o npm
echo "instalando as dependencias do npm"
cd /opt
echo "instalando express"
npm install express --save > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao instalar dependencia express"
  echo "processo cancelado"
  exit 1
fi
echo "instalando pm2"
npm install pm2 --save 2>&1&> /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao instalar dependencia pm2"
  echo "processo cancelado"
  exit 1
fi
echo "criando link da aplicacao"
ln -sf /opt/node_modules/pm2/bin/pm2 /usr/bin/pm2 > /dev/null && \
ln -sf /opt/node_modules/pm2/bin/pm2-dev /usr/bin/pm2-dev > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao criar link da dependencia pm2"
  echo "processo cancelado"
  exit 1
fi

# instalacao de rotatividade de logs
echo "criando rotatividade de logs"
pm2 logrotate > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao criar rotatividade de logs"
  echo "processo cancelado"
  exit 1
fi

# reiniciando o nginx
echo "reiniciando o servidor web"
systemctl restart nginx > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao reiniciar servidor web"
  echo "processo cancelado"
  exit 1
fi

# instalacao htop (sistema de gerenciamento de tarefas)
echo "instalando htop (sistema de gerenciamento de tarefas)"
apt-get install -y htop -q > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao instalar aplicacao htop"
  echo "processo cancelado"
  exit 1
fi

# iniciando a app
echo "iniciando a aplicacao node.js"
pm2 startup /opt/app.js -i 0 > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao iniciar aplicacao node.js"
  echo "processo cancelado"
  exit 1
fi

# reiniciando servico de crontab
echo "reiniciando servico de agendamento"
/etc/init.d/cron restart > /dev/null
if [ $? -ne 0 ]; then
  echo "erro ao reiniciar servico de agendamento"
  echo "processo cancelado"
  exit 1
else
  echo "processo concluido com sucesso"
fi

# ajuda
echo
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
