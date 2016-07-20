FROM ubuntu:16.04

# system update
RUN apt update && apt upgrade -y

# install node.js
COPY node-v4.4.7.tar.gz /src/node-v4.4.7.tar.gz
RUN cd /src ; tar xvfz node-v4.4.7.tar.gz .



# installing dependencies 
COPY package.json /src/package.json
RUN cd /src; npm install

# Copia a app para a pasta src do container
COPY . /src

EXPOSE 8080
CMD ["node", "/src/index.js"]
