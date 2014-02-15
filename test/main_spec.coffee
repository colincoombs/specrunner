specrunner = require('..')
require('chai').should()

{Group, Example, Context, Main} = specrunner

#Group.trace = true
#Example.trace = true
#Context.trace = true
      
#return

describe 'Main', ->
  describe 'constructor()', ->
    it 'works', ->
      m = new Main()

  #describe 'run()', (done) ->
  #  it 'works?', ->
  #    m = new Main(format: true)
  #    m.run('../test_data/test.coffee')
  #    .then( (xc) ->
  #      xc.should.equal(1)
  #      done()
  #    )
