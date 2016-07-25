#!/bin/bash

echo
echo "Teste de Carga - Benchmarking"
echo
echo "Executando teste com 500 conexões em 15 segundos"
siege -d10 -c500 -t15s http://127.0.0.1/
echo
echo "Executando teste com 1000 conexões em 15 segundos"
siege -d10 -c1000 -t15s http://127.0.0.1/
echo
echo "Executando teste com 2500 conexões em 15 segundos"
siege -d10 -c2500 -t15s http://127.0.0.1/
echo

# número de falhas do último teste de benchmarking
ultimo_resultado=$(tail -n 1 /var/log/siege.log | awk -F" " '{ print $11 }')
if [ ${ultimo_resultado} -gt 0 ]; then
  echo "Estão ocorrendo falhas nos testes de benchmarking"
  echo "Número de falhas encontradas no último teste: ${ultimo_resultado}"
else
  echo "Não estão ocorrendo falhas"
fi

echo "Demonstrativo dos últimos dez testes de benchmarking"
tail -n 10 /var/log/siege.log

exit 0
