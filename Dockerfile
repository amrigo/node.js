FROM ubuntu:16.04

# atualiza o sistema ubuntu
RUN apt-get update 

# instala o python
RUN apt-get install python -y

# instala compiladores
RUN apt-get install make -y
RUN apt-get install g++ -y

# instala o node.js
RUN wget -O /opt/node-v4.4.7.tar.gz https://nodejs.org/dist/v4.4.7/node-v4.4.7.tar.gz
RUN cd /opt/
RUN tar xvfz /opt/node-v4.4.7.tar.gz
RUN cd /opt/node-v4.4.7/
RUN ./configure && make && make install

# instala a dependencia express
COPY package.json /opt/package.json
RUN cd /opt/
RUN npm install

# copia o app para a pasta src do container
COPY . /opt

# habilita a porta 3000 para execucao do app
EXPOSE 3000
CMD ["node", "/opt/index.js"]
