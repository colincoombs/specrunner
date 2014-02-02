specrunner = require('..')
require('chai').should()

describe 'Main', ->
  describe 'constructor()', ->
    it 'works', ->
      m = new specrunner.Main()

  describe 'run()', ->
    it 'works?', ->
      m = new specrunner.Main()
      m.run().should.equal(1)
