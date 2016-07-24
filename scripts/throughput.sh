#!/bin/bash

echo "Teste de Carga - Benchmarking"

echo "Digite o numero de requisicoes:"
printf "> " && read requisicoes
echo "Digite o numero de usuarios:"
printf "> " && read usuarios
ab -n ${requisicoes} -c ${usuarios} http://127.0.0.1/
