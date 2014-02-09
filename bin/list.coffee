#! /usr/bin/env coffee

options    = require('commander')
Q          = require('q')
specrunner = require('..')
stream     = require('stream')
util       = require('util')

options
  .option('-n, --name', 'name of the database file storage')
  .version('0.0.1')
  .parse(process.argv)

options.name ?= './db'

class PromisedTransform extends stream.Transform

  @new: (stream, options, _class = PromisedTransform) ->
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

class L extends PromisedTransform

  _transform: (item, args...) ->
    console.log item
    @resolution ?= 0
    @resolution += 1
    super(item, args...)

specrunner.Database.open(options.name)
.then( (db) =>
  #console.log 'opened'#, db
  db.put 'a', 'A'
  db.put 'b', 'B'
  db.put 'c', 'C'
  db.del('b')
  db.stream()
).then( (stream) =>
  #console.log 'got stream'#, stream
  PromisedTransform.new(stream, {}, L)
).done(console.log)
