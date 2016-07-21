FROM ubuntu:16.04

# atualiza o sistema ubuntu
RUN apt-get update && apt-get upgrade -y

# instala o npm
RUN apt-get install npm -y

# instala o python
RUN apt-get install python -y

# instala compiladores
RUN apt-get install make g++ -y

# instala o node.js
COPY node-v4.4.7.tar.gz /src/node-v4.4.7.tar.gz
RUN cd /src
RUN tar xvfz node-v4.4.7.tar.gz
RUN cd node-v4.4.7
RUN ./configure && make && make install

# instala a dependencia express
COPY package.json /src/package.json
RUN cd /src
RUN npm install

# copia o app para a pasta src do container
COPY . /src

# habilita a porta 3000 para execucao do app
EXPOSE 3000
CMD ["node", "/src/index.js"]
