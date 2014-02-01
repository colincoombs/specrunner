specrunner = require('..')

class Example

  parent:  null
  name:    null
  body:    null
  results: null
  
  constructor: (@parent, @name, @body) ->
    @formatters = []
    @results = []
    if @parent?
      @parent.add(this)
    
  addFormatter: (formatter) ->
    @formatters.push(formatter)
  
  addResult: (result) ->
    @results.push(result)
    @formatResult(result)
  
  run: () ->
    context = new specrunner.Context(this)
    # @parent.runAllBeforeEach(context)
    @formatExampleStart(this)
    @body.call(context) if @body?
    unless @results.length > 0
      @addResult(new specrunner.Result(
        specrunner.Result.PEND, 'not yet implemented')
      )
    @formatExampleEnd(this)
    # @parent.runAllAfterEach(context)
  
  summarizeTo: (summary) ->
    summary.add(result) for result in @results
  
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
