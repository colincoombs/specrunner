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
    @formatExampleStart(this)
    @before().then( =>
      @action()
    ).then( =>
      @after()
    ).then( =>
      @deferred.resolve()
      Q()
    ).fail( (err) =>
      @deferred.reject(err)
    ).finally( =>
      unless @results.length > 0
        @addResult(new specrunner.Result(
          specrunner.Result.PEND, 'not yet implemented')
        )
      @formatExampleEnd(this)
    )
    return @deferred.promise
  
  before: () ->
    #console.log 'before'
    if @parent?
      @parent?.runAllBeforeEach(context)
    else
      Q()
    
  action: () ->
    #console.log 'action'
    if @body?
      Q.fcall( => @body.call(context) )
      #.fail(
      #  @addResult(new specrunner.Result(
      #    specrunner.Result.FAIL,
      #    err
      #  ))
      #)
    else
      Q()
  
  after: () ->
    #console.log 'after'
    if @parent?
      @parent?.runAllAfterEach(context)
    else
      Q()
 
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
