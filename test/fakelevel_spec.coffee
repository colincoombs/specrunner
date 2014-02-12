stream = require('stream')
util = require('util')
Q = require('q')
specrunner = require('..')
chai = require('chai')
chai.should()
expect = chai.expect

{level, StreamPromise} = specrunner

describe 'Fake level', ->
  
  beforeEach ->
    console.log 'before'
    @db = level(':memory:')
    @db.db.on('error', console.error)
    
  afterEach ->
    @db.close()
    console.log 'after'
    
  describe 'level', ->
    it 'works', ->
      expect(@db).not.to.be.null
      
  describe 'put(key, value)', ->
    
    it 'works', ->
      (=> @db.put('k', 'v')).should.not.throw(Error)
  
    it 'can update as well', (done) ->
      Q.ninvoke(@db, 'put', 'a', 'A1')
      .then( =>
        Q.ninvoke(@db, 'put', 'a', 'A2')
      ).then( =>
        Q.ninvoke(@db, 'get', 'a')
      ).then( (result) ->
        Q(
          expect(result).to.equal('A2')
          done()
        )
      ).done()
      
  describe 'get(key)', ->
    
    it 'works', (done) ->
      Q.ninvoke(@db, 'put', 'b', 'B')
      .then( =>
        Q.ninvoke(@db, 'get', 'b')
      ).then( (result) ->
        Q(
          expect(result).to.equal('B')
          done()
        )
      ).done()
  
    it 'returns null for unknown key', (done) ->
      Q.ninvoke(@db, 'get', 'crap')
      .then( (result) ->
        Q(
          expect(result).to.be.null
          done()
        )
      ).done()

  describe 'createReadStream()', ->
    
    it 'can read everything', (done) ->
      Q.ninvoke(@db, 'put', 'b', 'B')
      .then( =>
        Q.ninvoke(@db, 'put', 'a', 'A')
      ).then( =>
        Q.ninvoke(@db, 'createReadStream', {})
      ).then( (str) =>
        StreamPromise.new str, (item) ->
          @resolution ?= []
          @resolution.push item
      ).then( (result) ->
        Q(
          expect(result).to.deep.equal([
            {key:'a',value:'A'},
            {key:'b',value:'B'}
          ])
          done()
        )
      ).done()
  
    it 'can take a start point', (done) ->
      Q.ninvoke(@db, 'put', 'c', 'C')
      .then( =>
        Q.ninvoke(@db, 'put', 'a', 'A')
      ).then( =>
        Q.ninvoke(@db, 'put', 'b', 'B')
      ).then( =>
        Q.ninvoke(@db, 'createReadStream', {start: 'b'})
      ).then( (str) =>
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
      Q.ninvoke(@db, 'put', 'c', 'C')
      .then( =>
        Q.ninvoke(@db, 'put', 'a', 'A')
      ).then( =>
        Q.ninvoke(@db, 'put', 'b', 'B')
      ).then( =>
        Q.ninvoke(@db, 'createReadStream', {end: 'b'})
      ).then( (str) =>
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
      Q.ninvoke(@db, 'put', 'c', 'C')
      .then( =>
        Q.ninvoke(@db, 'put', 'a', 'A')
      ).then( =>
        Q.ninvoke(@db, 'put', 'b', 'B')
      ).then( =>
        Q.ninvoke(@db, 'createReadStream', {reverse: true})
      ).then( (str) =>
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
      Q.ninvoke(@db, 'put', 'c', 'C')
      .then( =>
        Q.ninvoke(@db, 'put', 'a', 'A')
      ).then( =>
        Q.ninvoke(@db, 'put', 'b', 'B')
      ).then( =>
        Q.ninvoke(@db, 'createReadStream', {reverse: true, limit: 2})
      ).then( (str) =>
        StreamPromise.new str, (item) ->
          @resolution ?= []
          @resolution.push item.value
      ).then((result) ->
          Q(
            expect(result).to.deep.equal(['C', 'B'])
            done()
          )
      ).done()
