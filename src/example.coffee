Q          = require('q')
specrunner = require('..')

# AARGH
# why the F*** do I have to write 'specrunner.Result'
# /AARGH

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
  run: (@db) ->
    console.log 'Example#run', @name if Example.trace
    context = new specrunner.Observation(this, @db)
    @formatExampleStart(this)
    
    @before(context).then( =>
      console.log 'DONE BEFORE'
      @action(context)
    ).then( =>
      console.log 'DONE ACTION'
      @after(context)
    ).catch( (err) =>
      @addResult(specrunner.Result.fail(err))
    ).finally( =>
      unless @results.length > 0
        @addResult(specrunner.Result.pend('not yet implemented'))
      @formatExampleEnd(this)
    )
    
  before: (context) ->
    console.log 'Example#before' if Example.trace
    Q(@parent?.runAllBeforeEach(context))
    
  action: (context) ->
    console.log 'Example#action' if Example.trace
    rc = @body?.call(context)
    console.log 'BODY RETURNS', rc
    Q(rc)
  
  after: (context) ->
    console.log 'Example#after' if Example.trace
    Q(@parent?.runAllAfterEach(context))
 
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
