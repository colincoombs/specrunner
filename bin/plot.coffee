#! /usr/bin/env coffee
# plot.coffee

child      = require('child_process')
options    = require('commander')
Q          = require('q')
specrunner = require('..')
stream     = require('stream')
util       = require('util')

Q.longStackSupport = true
{level, Database} = specrunner
#Database.trace = true

options
  .option('-n, --name <n>', 'name of the database file storage')
  .option('-x, --prefix <x>', 'prefix for all keys in database')
  .version('0.0.1')
  .parse(process.argv)

options.name ?= './db.sqlite'
options.timeFactor = 1/1000
options.tmax = 180

dbOptions = {}
if options.prefix?
  dbOptions.prefix = [options.prefix]
else
  dbOptions.prefix = []

gnuplot = null

console.log '1. here we go'

Q.fcall(level, options.name) # , trace: true

.then( (level) =>

  console.log '2. got level'
  Database._level = level
  Database.open(options.name, dbOptions)

).then( (db) =>

  console.log '3. got db'

  gnuplot = child.spawn '/usr/bin/gnuplot', ['--persist']
  gnuplot.stdout.pipe(process.stdout)
  gnuplot.stderr.pipe(process.stderr)
  gnuplot.on('error', (e)->
    console.log 'gnuplot subprocess error',e
  )
  
  new specrunner.Plot(db, gnuplot.stdin, options).go()

).then( (db) =>

  Database.shutdown()
  
).done(

  console.log '7. done()'

)
