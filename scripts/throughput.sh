#!/bin/bash

dia=$(date +%d-%m-%Y)

log="/relatorios/throughput/${dia}.log"

echo > $log
echo "Teste de Carga - Benchmarking" >> $log
echo >> $log
echo "Executando teste com 500 conexões em 15 segundos" >> $log
siege -d10 -c500 -t15s http://127.0.0.1/ >> $log
echo >> $log
echo "Executando teste com 1000 conexões em 15 segundos" >> $log
siege -d10 -c1000 -t15s http://127.0.0.1/ >> $log
echo >> $log
echo "Executando teste com 2500 conexões em 15 segundos" >> $log
siege -d10 -c2500 -t15s http://127.0.0.1/ >> $log
echo >> $log

# número de falhas do último teste de benchmarking
ultimo_resultado=$(tail -n 1 /var/log/siege.log | awk -F" " '{ print $11 }')
if [ ${ultimo_resultado} -gt 0 ]; then
  echo "Estão ocorrendo falhas nos testes de benchmarking" >> $log
  echo "Número de falhas encontradas no último teste: ${ultimo_resultado}" >> $log
else
  echo "Não estão ocorrendo falhas" >> $log
fi

echo "Demonstrativo dos últimos dez testes de benchmarking" >> $log
tail -n 10 /var/log/siege.log >> $log

# enviando email para root com o demonstrativo
cat ${log} | mail -s "Relatório de Teste de Carga - Throughput no Servidor Web" root@$HOSTNAME

exit 0
