#!/bin/bash

echo "Teste de Carga - Benchmarking"
echo
siege -d10 -c50 -t30s http://127.0.0.1/
