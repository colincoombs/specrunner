specrunner = require('./lib')

module.exports = ->
  @describe 'woof', ->
    @it 'works', ->
      @addResult(specrunner.Result.PASS, 'easy')
    @it 'fails', ->
      @addResult(specrunner.Result.FAIL, 'oops')
    @it 'aint ready for business', ->
      @addResult(specrunner.Result.PEND, 'one day')
    @it 'nope'
