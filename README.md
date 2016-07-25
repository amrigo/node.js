<div align="center">
  <a href="https://nodejs.org/en/">
    <img width=710px src="https://github.com/brunotougeiro/node.js/blob/master/web/nodejs-logo.png">
  </a>

  <br/>
  <br/>
</div>

Bem-vindos, <br/>
neste projeto irei abordar uma aplicação simples utilizando o Node.JS + PM2 (Balanceamento de Carga e Cluster) + Linux + Nginx (Proxy Reverso). <br/>

Para executar corretamente a aplicação, tenha instalado o Ubuntu 16.04 LTS. <br/>

[Node.JS](https://nodejs.org/en/) Versão: v4.4.7 # Servidor para aplicações web <br/>
[Express](http://expressjs.com) Versão: v4.14.0 # Web framework para Node.js <br/>
[PM2](https://www.npmjs.com/package/pm2) Versão: v1.1.3 # Controla a aplicação usando tecnologia de cluster e load balance <br/>
[npm](https://www.npmjs.com) Versão: v2.15.8 # Instalador de módulos <br/>

## NOTA: Quando instalar o serviço de email, escolha:
1) Internet Site <br/>
2) System mail name: $HOSTNAME

## Navegando nas pastas da aplicação

```bash
$ install.sh            # Script de instalação da aplicação.
$ app.js		# Script de exemplo que exibe "Hello World" no navegador http://<seu_ip> ou https://<seu_ip>.
$ cert.crt		# Chave ssl para acesso https.
$ cert.key		# Chave ssl para acesso https.
$ frequencia_web.sh	# Script que gera o relatório por código http de acessos diariamente eviador por e-mail.
$ reboot_services.sh	# Script que verifica se o servidor web e aplicação node estão ativos.
$ throughput.sh		# Script que gera teste de carga no servidor, e gera relatório enviado por e-mail.
$ uproll.sh		# Script que atualiza de forma segura a versão da aplicação.
$ default		# Arquivo de configuração do nginx para HA e proxy reverso e acesso https.
```

## Comandos úteis

```bash
$ pm2 list		# Lista todos os processos iniciados pelo PM2.
$ pm2 monit		# Mostra uso de memória e processador da aplicação.
$ pm2 show [app-name]	# Mostra todas as informações sobre a aplicação.
$ pm2 logs		# Mostra os logs de todas as aplicações.
```

### Para mais comandos sobre a aplicação PM2
Repositório da aplicação: [PM2](https://github.com/Unitech/pm2)

## Obrigado
