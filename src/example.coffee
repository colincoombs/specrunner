Q          = require('q')
specrunner = require('..')

class Example

  parent:     null
  name:       null
  body:       null
  results:    []
  formatters: []
  @trace: false
  
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
  run: () =>
    console.log 'Example#run', @name if Example.trace
    @deferred = Q.defer()
    context = new specrunner.Context(this)
    @formatExampleStart(this)
    @before(context).then( =>
      @action(context)
    ).then( =>
      @after(context)
    ).then( =>
      Q(@deferred.resolve())
    ).catch( (err) =>
      Q(@deferred.reject(err))
    ).finally( =>
      unless @results.length > 0
        @addResult(new specrunner.Result(
          specrunner.Result.PEND, 'not yet implemented')
        )
      @formatExampleEnd(this)
    )
    return @deferred.promise
  
  before: (context) ->
    console.log 'before' if Example.trace
    if @parent?
      @parent.runAllBeforeEach(context)
    else
      Q()
    
  action: (context) ->
    console.log 'action' if Example.trace
    if @body?
      Q(@body.call(context))
      #.fail(
      #  @addResult(new specrunner.Result(
      #    specrunner.Result.FAIL,
      #    err
      #  ))
      #)
    else
      Q()
  
  after: (context) ->
    console.log 'after' if Example.trace
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
