FROM ubuntu:16.04

# atualiza o sistema ubuntu
RUN apt-get update 

# instala o python
RUN apt-get install python -y

# instala compiladores
RUN apt-get install make -y
RUN apt-get install g++ -y

# instalando o wget
RUN apt-get install wget -y

# instala o node.js
RUN wget -O /opt/node-v4.4.7.tar.gz https://nodejs.org/dist/v4.4.7/node-v4.4.7.tar.gz
RUN tar xvfz /opt/node-v4.4.7.tar.gz
RUN cd /opt/node-v4.4.7/
RUN python configure
RUN make
RUN make install

# instala a dependencia express
COPY package.json /opt/package.json
RUN cd /opt/
RUN npm install

# copia o index para a pasta opt do container
COPY index.js /opt/index.js

# habilita a porta 3000 para execucao do app
EXPOSE 3000
CMD ["node", "/opt/index.js"]
