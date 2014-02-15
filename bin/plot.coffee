#! /usr/bin/env coffee
# plot.coffee

child      = require('child_process')
options    = require('commander')
Q          = require('q')
specrunner = require('..')
stream     = require('stream')
util       = require('util')

Q.longStackSupport = true
{level, Database, Plot} = specrunner

options
  .option('-n, --name <n>', 'name of the database file storage')
  .option('-d, --debug', 'enable loads ot tracingg and stuff')
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

if options.debug
  dbOptions.trace = true
  Database.trace = true
  Plot.trace = true

gnuplot = null
db = null

console.log '1. here we go'

Database.open(options.name, dbOptions)
.then( (_db) =>

  console.log '3. got db'

  db = _db
  gnuplot = child.spawn '/usr/bin/gnuplot', ['--persist']
  gnuplot.stdout.pipe(process.stdout)
  gnuplot.stderr.pipe(process.stderr)
  gnuplot.on('error', (e)->
    console.log 'gnuplot subprocess error',e
  )
  
  new specrunner.Plot(db, gnuplot.stdin, options).go()

).then( (db) =>
  console.log 'plotted'

  Database.shutdown()
  
).done()
