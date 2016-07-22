var cluster = require('cluster');
var os = require('os');
var cpus = os.cpus().length;

if ( cpus > 0 || cpus <= 32 )
{
  if (cluster.isMaster)
  {
    for (var i = 0; i <= cpus; i++)
    {
      cluster.fork();
    }

    cluster.on('listening', function(worker)
    {
      console.log('Cluster %d esta conectado.', worker.process.pid);
    });

    cluster.on('disconnect', function(worker)
    {
      console.log('Cluster %d esta desconectado.', worker.process.pid);
    });

    cluster.on('exit', function(worker)
    {
      console.log('Cluster %d caiu fora.', worker.process.pid);
    });
  }
  else
  {
    require('./app');
  }
}
