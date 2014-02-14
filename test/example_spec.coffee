specrunner = require('..')
Q          = require('q')
require('chai').should()

{Group, Example} = specrunner

# get some spying tools -- sinon?

describe 'Example', ->
  
  describe 'constructor()', ->

    it 'works', ->

    # with a parent, it gets added

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
      
      it 'returns a promise which will be rejected', (done) ->
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
          done(new Error('promise was not rejected'))
        , (err) ->
          done()
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

      it 'returns a promise which will be rejected', (done) ->
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
          done(new Error('promise was not rejected'))
        , (err) ->
          done()
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

    describe 'with nested before and after actions', ->
      it 'runs them before', (done) ->
        g1 = new Group(null, 'G1')
        g1.addBeforeEach( -> console.log 'G1B1')
        g1.addAfterEach( -> console.log 'G1A1')
        g2 = new Group(g1, 'G2')
        g2.addBeforeEach( -> console.log 'G2B1')
        g2.addAfterEach( -> console.log 'G2A1')
        e = new Example(g2, 'G2E1', -> console.log 'G2E1')
        e.run()
        .then =>
          done()
        .catch (err) =>
          done(err)
        
  # ditto that fail
  # with after functions
  # ditto that fail
  # format before/after

  # addResult
  #  formats result
  # summarizeTo
  # formatSummary