FROM ubuntu:16.04

# atualiza o sistema ubuntu
RUN apt-get update

# instala o node.js
COPY node-v4.4.7.tar.gz /opt/node-v4.4.7.tar.gz
RUN tar xvfz /opt/node-v4.4.7.tar.gz -C /opt/
RUN ln -s /opt/node-v4.4.7-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
RUN ln -s /opt/node-v4.4.7-linux-x64/bin/node /usr/bin/node

# instala a dependencias npm
RUN cd /opt/
RUN npm config set prefix "/opt/node_modules"
RUN npm install express --save
RUN npm install cluster-service --save
RUN npm install os --save
RUN npm install http --save

# instala o servico de cluster do node.js
RUN npm install cluster-service --save

# copia os arquivos para a pasta opt do container
COPY app.js /opt/app.js

# habilita a porta 3000 para execucao do app
EXPOSE 3000
CMD ["node", "/opt/app.js"]
