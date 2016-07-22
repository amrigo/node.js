var cluster = require('cluster');
var http = require('http');
var os = require('os');
var express = require('express');
var app = express();
var cpuCount = os.cpus().length;

if (cluster.isMaster && cpuCount > 0 || cpuCount <= 32)
{
  for (var i = 0; i < cpuCount; i++)
  {
    cluster.fork();
  }

  cluster.on('exit', function (worker)
  {
    console.log('Worker %d died :(', worker.id);
    cluster.fork();
  });
}
else
{
  app.get('/', function (request, response)
  {
    console.log('Request to worker %d', cluster.worker.id);
    response.send('Hello from Worker ' + cluster.worker.id);
  });

  app.listen(3000);
  console.log('Worker %d running!', cluster.worker.id);

  http.createServer(function(req, res)
  {
    res.writeHead(200);
    res.end("Hello World!");
  }).listen(3000);
}
