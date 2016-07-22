var cluster = require('cluster');
var numCPUs = require('os').cpus().length;

if (cluster.isMaster && numCPUs > 0 || numCPUs <= 32) {

  for (var i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', function(worker, code, signal) {
    console.log('worker ' + worker.process.pid + ' died');
  });
} else {
    require("./app.js");
}
