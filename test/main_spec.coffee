specrunner = require('..')
require('chai').should()

{Group, Example, Context} = specrunner

#Group.trace = true
#Example.trace = true
#Context.trace = true
      
#return

describe 'Main', ->
  describe 'constructor()', ->
    it 'works', ->
      m = new specrunner.Main()

  describe 'run()', ->
    it 'works?', ->
      m = new specrunner.Main()
      xc = m.run('../test_data/test.coffee')
      xc.should.equal(1)
