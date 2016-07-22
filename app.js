var express=require("express");
var app=express();

app.get('/',function(req,res){

          res.end("Hello world !");

});

app.listen(3000,function(){

          console.log("Running at PORT 3000");

});
