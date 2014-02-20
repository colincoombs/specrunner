Q          = require('q')
specrunner = require('..')
util       = require('util')

class Group extends specrunner.Example

  examples: []
  
  beforeEach: []
    
  afterEach: []
  
  current: null
  
  @trace: false
  
  constructor: (parent, name) ->
    console.log 'Group#constructor', name if Group.trace
    super(parent, name)
    @examples   = []
    @beforeEach = []
    @afterEach  = []
    @current    = null
  
  add: (child) ->
    console.log('Group#add', @name, child.name) if Group.trace
    @examples.push(child)
  
  addBeforeEach: (action) ->
    console.log 'Group#addBeforeEach', @name if Group.trace
    @beforeEach.push(action)
  
  addAfterEach: (action) ->
    console.log 'Group#addAfterEach', @name if Group.trace
    @afterEach.push(action)
  
  run: (@db) ->
    console.log 'Group#run', @name, @examples.length if Group.trace
    @formatGroupStart(this)
    @promiseRemainingExamples(@examples)
    .then =>
      @formatGroupEnd(this)
  
  promiseRemainingExamples: (examples) ->
    console.log(
      'Group#promiseRemainingExamples',
      @name,
      examples.length
    ) if Group.trace
    if examples.length > 0
      [first, theRest...] = examples
      first.run(@db)
      .then =>
        @promiseRemainingExamples(theRest)
    else
      Q()
    
  runAllBeforeEach: (context) ->
    console.log 'Group#runAllBeforeEach', @name if Group.trace
    Q(@parent?.runAllBeforeEach(context))
    .then( =>
      console.log "Group#parent resolved", @name if Group.trace
      @promiseAllActions(context, @beforeEach)
    ).catch( (err) ->
      console.log 'AARGH', err if Group.trace
      throw err
    )
    
  runAllAfterEach: (context) ->
    console.log 'Group#runAllAfterEach', @name if Group.trace
    @promiseAllActions(context, @afterEach)
    .then( =>
      Q(@parent?.runAllAfterEach(context))
    )
    
  promiseAllActions: (context, actions) ->
    console.log 'Group#promiseAllActions', @name, actions.length if Group.trace
    Q(
      if actions.length > 0
        console.log 'Group#action call', @name if Group.trace
        [first, theRest...] = actions
        Q(first.call(context))
        .then =>
          console.log "Group#action resolved", @name if Group.trace
          @promiseAllActions(context, theRest)
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
