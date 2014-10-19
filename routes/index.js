var express = require('express');
var router = express.Router();
var _ = require('lodash');

var ip = _.flatten(_.values(require('os').networkInterfaces())).filter(function(iface){
  return iface.family === 'IPv4' && iface.address !== '127.0.0.1';
}).map(function(iface){
  return iface.address;
})[0];
console.log(ip);
    
/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { 
    ip: ip
  });
});

module.exports = router;
