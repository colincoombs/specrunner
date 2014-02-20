#! /usr/bin/env coffee

options    = require('commander')
specrunner = require('..')

{Main, Group, Example, Context, Database, Spec} = specrunner


options
  .option('-p, --permissive', 'accept specifications with pending steps')
  .option('-d, --debug', 'enable loads ot tracingg and stuff')
  .option('-f, --format', 'enable result formatter')
  # --grep
  # --invert
  # --timeout ?
  .version('0.0.1')
  .parse(process.argv)

options.debug ?= false

Main.trace    = options.debug
Spec.trace    = options.debug
Group.trace   = options.debug
Example.trace = options.debug
Context.trace = options.debug

Database.open()
.then (db) ->
  main = new specrunner.Main(db, options)
  main.run(options.args...)
.then( (exitCode) =>
  console.log 'exitCode', exitCode if options.debug
  process.exit(exitCode)
)

