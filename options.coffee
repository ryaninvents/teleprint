opts = require 'nomnom'
  .option 'port',
    abbr: 'p'
    help: 'Select which port to run on'
  .option 'address',
    abbr: 'a'
    help: 'Set the address to listen on (default is localhost)'
  .option 'any-address',
    help: 'Respond to requests to any address (insecure)'
    flag: yes
  .option 'sim',
    abbr: 's'
    flag: yes
    help: 'Enable simulated printers'
  .parse()


opts.port ?= process.env.PORT or 3000

if opts['any-address']
  opts.address ?= '0.0.0.0'

opts.address ?= 'localhost'

module.exports = opts
