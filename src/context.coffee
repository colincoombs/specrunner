specrunner = require('..')

class Context

  @trace: false
  
  constructor: (@_example) ->
    console.log 'Context#constructor' if Context.trace
    
  addResult: (kind, description) =>
    console.log 'Context#addResult', kind, description if Context.trace
    @_example.addResult(new specrunner.Result(kind, description))
  
  pending: (description) ->
    @addResult(specrunner.Result.PEND, description)

  expect: (actual, expected=true, errorDescription) ->
    if actual is expected
      @addResult(specrunner.Result.PASS)
    else
      @addResult(specrunner.Result.FAIL, errorDescription)
      
module.exports = Context
