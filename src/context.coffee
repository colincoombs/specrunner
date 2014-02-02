specrunner = require('..')

class Context

  constructor: (@_example) ->
    
  addResult: (kind, description) =>
    @_example.addResult(new specrunner.Result(kind, description))
  
  pending: (description) ->
    @addResult(specrunner.Result.PEND, description)

  expect: (actual, expected=true, errorDescription) ->
    if actual is expected
      @addResult(specrunner.Result.PASS)
    else
      @addResult(specrunner.Result.FAIL, errorDescription)
      
module.exports = Context
