stream     = require('stream')
util       = require('util')
Q          = require('q')
specrunner = require('..')
chai       = require('chai')

expect = chai.expect
chai.should()

level         = specrunner.level
Database      = specrunner.Database
StreamPromise = specrunner.StreamPromise

describe 'Wire', ->
  
  beforeEach (done) ->
    #console.log 'before'
    Database._level = level(':memory:')
    Database._level.db.on('error', console.error)
    Database.open().then( (db) =>
      #console.log 'opened', db
      @db = db
      done()
    ).done()
    
  afterEach ->
    delete @db
    Database.shutdown()
    #console.log 'after'
    
  describe 'constructor(db, name)', ->
    it 'works', ->
      w = new specrunner.Wire(@db, 'A')
    
  describe 'put(time,value)', ->
    
    it 'returns a promise', (done) ->
      #console.log 'db now', @db
      a = new specrunner.Wire(@db, 'A')
      p = a.put(0, 'x')
      expect(Q.isPromise(p)).to.be.true
      done()
      
  describe 'stream(options)', ->
    
    it 'streams everything', (done) ->
      a = new specrunner.Wire(@db, 'A')
      a.put(0, 'x')
      .then ->
        a.put(1, '0')
      .then ->
        a.put(5, '1')
      .then ->
        a.stream()
      .then (s) =>
        StreamPromise.new(s, (ev) ->
          @resolution ?= []
          @resolution.push ev
        )
      .then (result) ->
        expect(result).to.deep.equal([
          { key:'A~00000000', value:'x'},
          { key:'A~00000001', value:'0'},
          { key:'A~00000005', value:'1'},
        ])
        done()
      .catch (e) ->
        done(e)
    
  describe 'promiseToPipe', ->
    it 'streams everything', (done) ->
      a = new specrunner.Wire(@db, 'A')
      a.put(0, 'x')
      .then ->
        a.put(1, '0')
      .then ->
        a.put(5, '1')
      .then ->
        a.promiseToPipe(process.stdout)
      #.then (s) =>
      #  StreamPromise.new(s, (ev) ->
      #    @resolution ?= []
      #    @resolution.push ev
      #  )
      .then (result) ->
        #expect(result).to.deep.equal([
        #  { key:'A~00000000', value:'x'},
        #  { key:'A~00000001', value:'0'},
        #  { key:'A~00000005', value:'1'},
        #])
        done()
      .catch (e) ->
        done(e)
