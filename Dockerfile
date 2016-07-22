FROM ubuntu:16.04

# atualiza o sistema ubuntu
RUN apt-get update

# instala o node.js
COPY node-v4.4.7.tar.gz /opt/node-v4.4.7.tar.gz
RUN tar xvfz /opt/node-v4.4.7.tar.gz -C /opt/
RUN ln -s /opt/node-v4.4.7-linux-x64/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
RUN ln -s /opt/node-v4.4.7-linux-x64/bin/node /usr/bin/node

# instala a dependencia express
COPY package.json /opt/package.json
RUN npm install /opt/

# copia os arquivos para a pasta opt do container
COPY app.js /opt/app.js
COPY cluster.js /opt/cluster.js

# habilita a porta 3000 para execucao do app
EXPOSE 3000
CMD ["node", "/opt/cluster.js"]
