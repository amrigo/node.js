#!/bin/bash

echo "Teste de Carga - Benchmarking"
ab -n ${requisicoes} -c ${usuarios} http://127.0.0.1/
