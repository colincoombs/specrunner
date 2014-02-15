Q          = require('q')
specrunner = require('..')

{Group, Example} = specrunner

chai = require('chai')
chai.should()
expect = chai.expect

describe 'Group', ->

  describe 'constructor(parent, name)', ->
    it 'works', ->
      ( -> g = new Group(null, 'G1')).should.not.throw(Error)
      
  describe 'run()', ->
    it 'returns a promise', ->
      g = new Group(null, 'G2')
      rc = g.run()
      Q.isPromise(rc).should.be.true

    describe 'with no examples', ->
      it 'succeeds', (done) ->
        g = new Group(null, 'G3')
        g.run()
        .then ->
          done()
        .catch (err) ->
          done(err)

    describe 'with a failing example', ->
      it 'succeeds', (done) ->
        g = new Group(null, 'G4')
        new Example(g, 'G4E1', (-> @expect(true, false, 'oops')))
        g.run()
        .then ->
          done()
        .catch (err) ->
          done(err)
        
    describe 'with several examples', ->
      it 'runs them all', (done) ->
        log = []
        g = new Group(null, 'G4')
        new Example(g, 'G4E1', (-> log.push 'E1'))
        new Example(g, 'G4E2', (-> log.push 'E2'))
        g.run()
        .then ->
          log.should.deep.equal(['E1','E2'])
          done()
        .catch (err) ->
          done(err)
        
  describe 'runAllBeforeEach()', ->
    
    it 'returns a promise', ->
      g = new Group(null, 'G5')
      rc = g.runAllBeforeEach()
      Q.isPromise(rc).should.be.true

    describe 'with no actions', ->
      it 'succeeds', (done) ->
        g = new Group(null, 'G6')
        g.runAllBeforeEach()
        .then ->
          done()
        .catch (err) ->
          done(err)

    describe 'with an empty action', ->
      it 'succeeds', (done) ->
        g = new Group(null, 'G7')
        g.addBeforeEach( -> )
        g.runAllBeforeEach()
        .then ->
          done()
        .catch (err) ->
          done(err)

    describe 'with an action that promises', ->
      it 'succeeds', (done) ->
        g = new Group(null, 'G7')
        g.addBeforeEach( -> Q() )
        g.runAllBeforeEach()
        .then ->
          done()
        .catch (err) ->
          done(err)

    describe 'with an action that throws', ->
      it 'rejects', (done) ->
        g = new Group(null, 'G8')
        g.addBeforeEach( -> throw new Error('thud'))
        g.runAllBeforeEach()
        .then ->
          done(new Error('this should not succeed'))
        .catch (err) ->
          expect(err.message).to.equal('thud')
          done()

    describe 'with an action that rejects', ->
      it 'rejects', (done) ->
        g = new Group(null, 'G8')
        g.addBeforeEach( -> Q.reject( new Error('ouch')))
        g.runAllBeforeEach()
        .then ->
          done(new Error('this should not succeed'))
        .catch (err) ->
          expect(err.message).to.equal('ouch')
          done()

    describe 'with multiple actions', ->
      it 'runs them all', (done) ->
        log = []
        g = new Group(null, 'G9')
        g.addBeforeEach( -> log.push 'B1')
        g.addBeforeEach( -> log.push 'B2')
        g.runAllBeforeEach()
        .then ->
          log.should.deep.equal(['B1','B2'])
          done()
        .catch (err) ->
          done(err)
          
    describe 'with a nested group', ->
      it 'runs the parents actions first', (done) ->
        log = []
        gp = new Group(null, 'GP1')
        gc = new Group(gp, 'GC1')
        gp.addBeforeEach( -> log.push 'GP1')
        gc.addBeforeEach( -> log.push 'GC1')
        gc.runAllBeforeEach()
        .then ->
          log.should.deep.equal(['GP1','GC1'])
          done()
        .catch (err) ->
          done(err)

  describe 'runAllAfterEach()', ->
    
    it 'returns a promise', ->
      g = new Group(null, 'G10')
      rc = g.runAllAfterEach()
      Q.isPromise(rc).should.be.true

    describe 'with no actions', ->
      it 'succeeds', (done) ->
        g = new Group(null, 'G11')
        g.runAllAfterEach()
        .then ->
          done()
        .catch (err) ->
          done(err)

    describe 'with an empty action', ->
      it 'succeeds', (done) ->
        g = new Group(null, 'G12')
        g.addAfterEach( -> )
        g.runAllAfterEach()
        .then ->
          done()
        .catch (err) ->
          done(err)

    describe 'with an action that rejects', ->
      it 'rejects', (done) ->
        g = new Group(null, 'G13')
        g.addAfterEach( -> Q.reject( new Error('ouch')))
        g.runAllAfterEach()
        .then ->
          done(new Error('this should not succeed'))
        .catch (err) ->
          expect(err.message).to.equal('ouch')
          done()

    describe 'with multiple actions', ->
      it 'runs them all', (done) ->
        log = []
        g = new Group(null, 'G14')
        g.addAfterEach( -> log.push 'A1')
        g.addAfterEach( -> log.push 'A2')
        g.runAllAfterEach()
        .then ->
          log.should.deep.equal(['A1','A2'])
          done()
        .catch (err) ->
          done(err)
          
    describe 'with a nested group', ->
      it 'runs the childs actions first', (done) ->
        log = []
        gp = new Group(null, 'GP2')
        gc = new Group(gp, 'GC2')
        gp.addAfterEach( -> log.push 'GP2')
        gc.addAfterEach( -> log.push 'GC2')
        gc.runAllAfterEach()
        .then ->
          log.should.deep.equal(['GC2','GP2'])
          done()
        .catch (err) ->
          done(err)
