#! /usr/bin/env coffee

options    = require('commander')
Q          = require('q')
specrunner = require('..')
stream     = require('stream')
util       = require('util')

options
  .option('-n, --name <n>', 'name of the database file storage')
  .option('-s, --start <k>', 'starting key')
  .option('-e, --end <k>', 'ending key')
  .option('-r, --reverse', 'go backwards?')
  .option('-l, --limit <n>', 'maximum number of entries to list', parseInt)
  .version('0.0.1')
  .parse(process.argv)

options.name ?= './db'

class PromisedTransform extends stream.Transform

  @new: (stream, _class = PromisedTransform, options) ->
    #console.log 'PromisedTransform.new'#, stream, options, _class
    q = Q.defer()
    stream.pipe(new _class(q, options))
    return q.promise
    
  constructor: (@q, options = {}) ->
    #console.log 'PromisedTransform#constructor', @q, options
    options.objectMode = true
    super(options)
    @resolution = null
  
  _transform: (item, _, done) ->
    done()
  
  _flush: (done) ->
    @q.resolve(@resolution)

class Gather extends PromisedTransform

  _transform: (item, args...) ->
    @resolution ?= {}
    @resolution[item.key] = item.value
    super(item, args...)

class Count extends PromisedTransform

  _transform: (item, args...) ->
    @resolution ?= 0
    @resolution += 1
    super(item, args...)

specrunner.Database.open(options.name)
.then( (db) =>
  #console.log 'opened'#, db
  db.put 'a', 'A'
  db.put 'b', 'B'
  db.put 'c', 'C'
  #db.del('b')
  db.stream(options)
).then( (stream) =>
  #console.log 'got stream'#, stream
  PromisedTransform.new(stream, Gather)
).done(console.log)
