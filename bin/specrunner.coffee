options    = require('commander')
specrunner = require('..')

{Main, Group, Example, Context} = specrunner


options
  .option('-p, --permissive', 'accept specifications with pending steps')
  .option('-d, --debug', 'enable loads ot tracingg and stuff')
  .option('-f, --format', 'enable result formatter')
  .version('0.0.1')
  .parse(process.argv)

options.debug ?= false

Main.trace    = options.debug
Group.trace   = options.debug
Example.trace = options.debug
Context.trace = options.debug

main = new specrunner.Main(options)
main.run(options.args...)
.then( (exitCode) =>
  console.log 'exitCode', exitCode
  process.exit(exitCode)
)

