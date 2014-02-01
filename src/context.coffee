specrunner = require('..')

class Context

  constructor: (@_example) ->
    
  addResult: (kind, description) =>
    @_example.addResult(new specrunner.Result(kind, description))
  

module.exports = Context
