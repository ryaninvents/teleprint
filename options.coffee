opts = require 'nomnom'
  .option 'port',
    abbr: 'p'
    help: 'Select which port to run on'
  .option 'sim',
    abbr: 's'
    flag: yes
    help: 'Enable simulated printers'
  .parse()


opts.port ?= process.env.PORT or 3000

module.exports = opts
