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

describe 'Database', ->
  
  beforeEach ->
    Database._level = level(':memory:')
    Database._level.db.on('error', console.error)
    
  afterEach ->
    Database.shutdown()
    
  describe 'Database.open', ->
    it 'works', (done) ->
      Database.open()
      .then (db) ->
        #console.log 'open OK'
        done()
      .catch (err) ->
        #console.log 'open NOK', err
        done(err)
      .done()
      
  describe 'put(key, value)', ->
    
    beforeEach (done) ->
      Database.open().then( (db) =>
        @db = db
        done()
      )
      
    it 'can insert', (done) ->
      @db.put('a', 'A')
      .then( =>
        @db.get('a')
      ).then( (result) =>
        Q(
          expect(result).to.equal('A')
          done()
        )
      ).done()
  
    it 'can update', (done) ->
      @db.put('a', 'A1')
      .then( =>
        @db.put('a', 'A2')
      ).then( =>
        @db.get('a')
      ).then( (result) ->
        Q(
          expect(result).to.equal('A2')
          done()
        )
      ).done()
      
  describe 'get(key)', ->
    
    beforeEach (done) ->
      Database.open().then( (db) =>
        @db = db
        done()
      )
      
    it 'works', (done) ->
      @db.put('b', 'B')
      .then( =>
        @db.get('b')
      ).then( (result) ->
        Q(
          expect(result).to.equal('B')
          done()
        )
      ).done()
  
    it 'errors for unknown key', (done) ->
      @db.get('crap')
      .then( (result) =>
        done(new Error ('should not succeed'))
      ).fail( (err) =>
        done()
      ).done()
  
  describe 'stream()', ->
    
    beforeEach (done) ->
      Database.open().then (db) =>
        @db = db
      .then =>
        @db.put('c', 'C')
      .then =>
        @db.put('a', 'A')
      .then =>
        @db.put('b', 'B')
      .then =>
        done()
      
    it 'can read everything', (done) ->
      @db.stream()
      .then( (str) =>
        StreamPromise.new str, (item) ->
          @resolution ?= []
          @resolution.push item
      ).then( (result) =>
        Q(
          expect(result).to.deep.equal([
            {key:'a',value:'A'},
            {key:'b',value:'B'},
            {key:'c',value:'C'}
          ])
          done()
        )
      ).done()
  
    it 'can take a start point', (done) ->
      @db.stream({start: 'b'})
      .then( (str) =>
        StreamPromise.new str, (item) ->
          @resolution ?= []
          @resolution.push item.value
      ).then((result) ->
          Q(
            expect(result).to.deep.equal(['B', 'C'])
            done()
          )
      ).done()
    
    it 'can take an end point', (done) ->
      @db.stream({end: 'b'})
      .then( (str) =>
        StreamPromise.new str, (item) ->
          @resolution ?= []
          @resolution.push item.value
      ).then((result) ->
          Q(
            expect(result).to.deep.equal(['A', 'B'])
            done()
          )
      ).done()
  
    it 'can stream in reverse', (done) ->
      @db.stream({reverse: true})
      .then( (str) =>
        StreamPromise.new str, (item) ->
          @resolution ?= []
          @resolution.push item.value
      ).then((result) ->
          Q(
            expect(result).to.deep.equal(['C', 'B', 'A'])
            done()
          )
      ).done()
  
    it 'can limit the number of results', (done) ->
      @db.stream({reverse: true, limit: 2})
      .then( (str) =>
        StreamPromise.new str, (item) ->
          @resolution ?= []
          @resolution.push item.value
      ).then((result) ->
          Q(
            expect(result).to.deep.equal(['C', 'B'])
            done()
          )
      ).done()
