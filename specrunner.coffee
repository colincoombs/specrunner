options    = require('commander')
specrunner = require('../specrunner')

options
  #.option('-p, --permissive', 'accept specifications with pending steps')
  .version('0.0.1')
  .parse(process.argv)

exitCode = specrunner.Main.run(options)

process.exit(exitCode)
