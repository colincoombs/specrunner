Q          = require('q')
specrunner = require('..')

class Example

  parent:     null
  name:       null
  body:       null
  results:    []
  formatters: []
  
  constructor: (@parent, @name, @body) ->
    @formatters = []
    @results = []
    if @parent?
      @parent.add(this)
    
  addResult: (result) ->
    @results.push(result)
    @formatResult(result)
  
  # Actually run the example
  # @return {Promise} for completion
  #
  run: () ->
    @deferred = Q.defer()
    context = new specrunner.Context(this)
    @parent.runAllBeforeEach(context).then( =>
      @formatExampleStart(this)
      # @TODO = set timeout & error if expired
      return Q.fcall(@body?.call(context))
    ).then( ->
    unless @results.length > 0
      @addResult(new specrunner.Result(
        specrunner.Result.PEND, 'not yet implemented')
      )
    ).then( =>
      @parent.runAllAfterEach(context)
    ).then( =>
      @formatExampleEnd(this)
      @deferred.resolve()
    )
    return @deferred.promise
  
  summarizeTo: (summary) ->
    summary.add(result) for result in @results
  
  addFormatter: (formatter) ->
    @formatters.push(formatter)
  
  formatExampleStart: (ex) ->
    if @parent?
      @parent.formatExampleStart(ex)
    else
      formatter.exampleStart(ex) for formatter in @formatters
      
  formatResult: (result) ->
    if @parent?
      @parent.formatResult(result)
    else
      formatter.result(result) for formatter in @formatters
    
  formatExampleEnd: (ex) ->
    if @parent?
      @parent.formatExampleEnd(ex)
    else
      formatter.exampleEnd(ex) for formatter in @formatters
      
  formatSummary: (summary) ->
    formatter.summary(summary) for formatter in @formatters
    
module.exports = Example
