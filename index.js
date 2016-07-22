var cluster = require('cluster');
var http = require('http');
var numCPUs = require('os').cpus().length;
var port = 3000

if (numCPUs > 0 || numCPUs <= 32)
{
  if(cluster.isMaster)
  {
    for (var i = 0; i < numCPUs; i++)
    {
      cluster.fork();
    }
  }
  else
  {
    http.createServer(function(req, res)
    {
      res.writeHead(200);
      res.send('Bem-vindo a aplicacao de teste Node.JS');
      res.send('Este e o processo ' + process.pid + ' em execução');
    }).listen(port);
  }
}
