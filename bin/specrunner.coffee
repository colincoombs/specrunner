options    = require('commander')
specrunner = require('..')

{Group, Example, Context} = specrunner


options
  .option('-p, --permissive', 'accept specifications with pending steps')
  .option('-d, --debug', 'enable loads ot tracingg and stuff')
  .option('-f, --format', 'enable result formatter')
  .version('0.0.1')
  .parse(process.argv)

options.debug ?= false

Group.trace   = options.debug
Example.trace = options.debug
Context.trace = options.debug

main = new specrunner.Main(options)
exitCode = main.run(options.args...)

process.exit(exitCode)
