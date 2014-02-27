specrunner = require('..')
Q          = require('q')
require('chai').should()

{Group, Example} = specrunner

# get some spying tools -- sinon?

describe 'Example', ->
  
  describe 'constructor()', ->

    it 'works'

    # with a parent, it gets added

  describe 'fullname', ->
    describe 'without a name', ->
      it 'is an empty array', ->
        e = new Example(null, null)
        e.fullname().should.deep.equal([])
    describe 'with a name and no parent', ->
      it 'is an array of the name', ->
        e = new Example(null, 'G')
        e.fullname().should.deep.equal(['G'])
    describe 'with a name and a null-named parent', ->
      it 'is an array of the name', ->
        p = new Group(null, null)
        e = new Example(p, 'G')
        e.fullname().should.deep.equal(['G'])
    describe 'with a name and a named parent', ->
      it 'is an array of the two names', ->
        p = new Group(null, 'P')
        e = new Example(p, 'G')
        e.fullname().should.deep.equal(['P', 'G'])

  describe 'run', ->
    
    describe 'without a body', (done) ->
      
      it 'returns a promise which will be resolved', ->
        # arrange
        ex = new specrunner.Example()
        # act
        rc = ex.run()
        # assert
        rc.then( (result) ->
          done(result)
        , (err) ->
          done(err)
        )

    describe 'with a body that fails', ->
      
      it 'returns a promise which will be fulfilled', (done) ->
        # arrange
        ex = new specrunner.Example(
          null,
          'name',
          ( ->
            throw new Error('oops')
          )
        )
        # act
        rc = ex.run()
        # assert
        rc.then( ->
          done()
        , (err) ->
          done(err)
        )
        
    describe 'with a body that returns a simple value', ->
      
      it 'returns a promise which will be resolved', (done) ->
        # arrange
        ex = new specrunner.Example(
          null,
          'name',
          ( ->
            return false
          )
        )
        # act
        rc = ex.run()
        # assert
        rc.then( (result) ->
          done(result)
        , (err) ->
          done(err)
        )
      
    describe 'with a body that returns a rejecting promise', ->

      it 'returns a promise which will be fulfilled', (done) ->
        # arrange
        ex = new specrunner.Example(
          null,
          'name',
          ( ->
            Q.reject('boo hoo')
          )
        )
        # act
        rc = ex.run()
        # assert
        rc.then( ->
          done()
        , (err) ->
          done(err)
        )
        
    describe 'with a body that returns a resolved promise', ->
      
      it 'returns a promise which will be resolved', (done) ->
        # arrange
        ex = new specrunner.Example(
          null,
          'name',
          ( ->
            return Q()
          )
        )
        # act
        rc = ex.run()
        # assert
        rc.then( (result) ->
          done(result)
        , (err) ->
          done(err)
        )

    describe 'with a before action that fails', ->
      it 'does not run the example', (done) ->
        log = []
        g2 = new Group(null, 'G')
        g2.addBeforeEach( ->
          log.push 'B'
          throw new Error 'splat'
        )
        e = new Example(g2, 'G2E1', -> log.push 'G2E')
        e.run()
        .then =>
          log.should.deep.equal ['B']
          done()
        .catch (err) =>
          done(err)

      it 'succeeds', (done) ->
        log = []
        g2 = new Group(null, 'G')
        g2.addBeforeEach( ->
          log.push 'B'
          throw new Error 'splat'
        )
        e = new Example(g2, 'G2E1', -> log.push 'G2E')
        e.run()
        .then =>
          done()
        .catch (err) =>
          done(err)
        
    describe 'with an after action that fails', ->

      it 'succeeds', (done) ->
        log = []
        g2 = new Group(null, 'G')
        g2.addAfterEach( ->
          log.push 'A'
          throw new Error 'splat'
        )
        e = new Example(g2, 'G2E1', -> log.push 'G2E')
        e.run()
        .then =>
          log.should.deep.equal(['G2E','A'])
          done()
        .catch (err) =>
          done(err)
        
    describe 'with nested before and after actions', ->
      it 'runs them in order', (done) ->
        log = []
        g0 = new Group(null, null)
        g1 = new Group(g0, 'G1')
        g1.addBeforeEach( -> log.push 'G1B')
        g1.addAfterEach(  -> log.push 'G1A')
        g2 = new Group(g1, 'G2')
        g2.addBeforeEach( -> log.push 'G2B')
        g2.addAfterEach(  -> log.push 'G2A')
        e = new Example(g2, 'G2E1', -> log.push 'G2E')
        g3 = new Group(g0, 'G3')
        e.run()
        .then =>
          log.should.deep.equal ['G1B','G2B','G2E','G2A','G1A']
          done()
        .catch (err) =>
          done(err)
        
    #describe 'with a body that returns a promise that times out', ->
    #  
    #  it 'returns a promise which will be resolved', (done) ->
    #    # arrange
    #    ex = new specrunner.Example(
    #      null,
    #      'name',
    #      ( ->
    #        return Q.defer().promise
    #      )
    #    )
    #    # act
    #    rc = ex.run()
    #    # assert
    #    rc.then( (result) ->
    #      done(result)
    #    , (err) ->
    #      done(err)
    #    )

  # ditto that fail
  # with after functions
  # ditto that fail
  # format before/after

  # addResult
  #  formats result
  # summarizeTo
  # formatSummary