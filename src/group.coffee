Q          = require('q')
specrunner = require('..')

class Group extends specrunner.Example

  examples: []
  
  beforeEach: []
    
  afterEach: []
  
  current: null
  
  constructor: (parent, name) ->
    super(parent, name)
    @examples   = []
    @beforeEach = []
    @afterEach  = []
    @current    = null
  
  add: (child) ->
    @examples.push(child)
  
  addBeforeEach: (action) ->
    @beforeEach.push(action)
  
  addAfterEach: (action) ->
    @afterEach.push(action)
  
  run: () ->
    @deferred = Q.defer()
    @formatGroupStart(this) if @parent?
    @remaining = @examples
    @runTheRemainingExamples()
    return @deferred.promise
  
  runTheRemainingExamples: () ->
    if @remaining.length == 0
      @formatGroupEnd(this) if @parent?
      @deferred.resolve()
    else
      example = @remaining.shift()
      @current = example
      example.run().then( =>
        @current = null
        @runTheRemainingExamples()
      ).fail( (err) ->
        # todo whatever
        throw err
      )
    
  runAllBeforeEach: (context) ->
    @deferredActions = Q.defer()
    @remainingActions = @beforeEach
    
    if @parent?
      @parent.runAllBeforeEach(context).then( =>
        @runRemainingBeforeEach()
      )
    else
      @runRemainingBeforeEach()
    return @deferredActions.promise

  runRemainingBeforeEach: () ->
    if @remainingActions.length == 0
      @deferredActions.resolve()
    else
      action = @remainingActions.shift()
      # @TODO = set timeout & error if expired
      Q.fcall(action.call(context)).then( =>
        @runRemainingBeforeEach()
      )
  
  runAllAfterEach: (context) ->
    @deferredActions = Q.defer()
    @remainingActions = @afterEach
    @runRemainingAfterEach()
    return @deferredActions.promise

  runRemainingAfterEach: () ->
    if @remainingActions.length == 0
      if @parent?
        @parent.runAllAfterEach(context).then( =>
          @deferredActions.resolve()
        )
      else
        @deferredActions.resolve()
    else
      action = @remainingActions.shift()
      # @TODO = set timeout & error if expired
      Q.fcall(action.call(context)).then( =>
        @runRemainingAfterEach()
      )
  
  summarizeTo: (summary) ->
    example.summarizeTo(summary) for example in @examples
    
  addResult: (result) ->
    @current.addResult(result)
  
  formatGroupStart: (gr) ->
    if @parent?
      @parent.formatGroupStart(gr)
    else
      formatter.groupStart(gr) for formatter in @formatters
    
  formatGroupEnd: (gr) ->
    if @parent?
      @parent.formatGroupEnd(gr)
    else
      formatter.groupEnd(gr) for formatter in @formatters

module.exports = Group
