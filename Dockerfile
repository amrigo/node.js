FROM ubuntu:16.04

# atualiza o sistema ubuntu
RUN apt-get update

# instala o node.js
COPY node-v4.4.7.tar.gz /opt/node-v4.4.7.tar.gz
RUN tar xvfz /opt/node-v4.4.7.tar.gz -C /opt/
RUN ln -s /opt/node-v4.4.7-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
RUN ln -s /opt/node-v4.4.7-linux-x64/bin/node /usr/bin/node

# instalando nginx para criar proxy reverso
RUN apt-get install nginx -y
COPY default /etc/nginx/sites-available/default
RUN service nginx restart

# instala a dependencia npm e aplicacoes usando npm
RUN cd /opt
RUN npm install express --save
RUN npm install cluster --save
RUN npm install os --save

# copia os arquivos para a pasta opt do container
COPY app.js /opt/app.js
COPY cluster.js /opt/cluster.js

# habilita a porta 3000 para execucao do app
EXPOSE 80 3000
CMD ["node", "/opt/cluster.js"]
