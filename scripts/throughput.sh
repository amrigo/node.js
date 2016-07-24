#!/bin/bash

echo "teste de carga no servidor"
echo "requisicoes: 10000"
echo "usuario concorrentes: 100"
ab -n 10000 -c 100 http://127.0.0.1/
