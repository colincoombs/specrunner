specrunner = require('..')
Q          = require('q')
require('chai').should()
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

  # with before functions
  # ditto that fail
  # with after functions
  # ditto that fail
  # format before/after

  # addResult
  #  formats result
  # summarizeTo
  # formatSummary