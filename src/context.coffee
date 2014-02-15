specrunner = require('..')

{Result} = specrunner

class Context

  @trace: false
  
  constructor: (@_example) ->
    console.log 'Context#constructor' if Context.trace
    
  pending: (description) ->
    @_example.addResult(specrunner.Result.pend(description))

  expect: (actual, expected=true, errorDescription) ->
    if actual is expected
      @_example.addResult(specrunner.Result.pass())
    else
      @_example.addResult(specrunner.Result.fail(errorDescription))
      
module.exports = Context
