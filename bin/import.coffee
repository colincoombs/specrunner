#! /usr/bin/env coffee

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
  .option('-f, --from <n>', 'name of vcd file to import')
  .option('-x, --prefix <x>', 'prefix for all keys in database')
  .version('0.0.1')
  .parse(process.argv)

options.name ?= './db.sqlite'

dbOptions = {}
if options.prefix?
  dbOptions.prefix = [options.prefix]
else
  dbOptions.prefix = []

console.log '1. here we go'
Q.fcall(level, options.name) # , trace: true
.then( (db) =>
  console.log '2. got level'
  Database._level = db
  Database.open(options.name, dbOptions)
).then( (db) =>
  console.log '3. got db'
  @db = db
  @db.get(['_metadata'])
).then( (json) =>
  console.log '4. got metadata'
  metadata = JSON.parse(json)
  if metadata.wires?
    Q()
  else
    metadata.wires = options.args
    @db.put(['_metadata'], JSON.stringify(metadata))
).then( =>
  console.log '5. updated metadata'
  new specrunner.Vcd(@db, options.from).run() 
).then( =>
  console.log '6. imported VCD'
  Q(specrunner.Database.shutdown())
).done(
  console.log '7. done()'
)

