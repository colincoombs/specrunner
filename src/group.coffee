Q          = require('q')
specrunner = require('..')

class Group extends specrunner.Example

  examples: []
  
  beforeEach: []
    
  afterEach: []
  
  current: null
  
  @trace: false
  
  constructor: (parent, name) ->
    console.log 'Group#constructor', @name if Group.trace
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
  
  run: () ->
    console.log 'Group#run', @name, @examples.length if Group.trace
    @formatGroupStart(this)
    @promiseRemainingExamples(e for e in @examples)
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
      first.run()
      .then =>
        @promiseRemainingExamples(theRest)
    else
      Q()
    
  runAllBeforeEach: (context) ->
    console.log 'Group#runAllBeforeEach', @name if Group.trace
    (if @parent?
      @parent.runAllBeforeEach(context)
    else
      Q()
    ).then =>
      @promiseAllActions(context, (a for a in @beforeEach))

  runAllAfterEach: (context) ->
    console.log 'Group#runAllAfterEach', @name if Group.trace
    @promiseAllActions(context, (a for a in @afterEach))
    .then =>
      if @parent?
        @parent.runAllAfterEach(context)
      else
        Q()

  promiseAllActions: (context, actions) ->
    console.log 'Group#promiseAllActions', @name, actions.length if Group.trace
    if actions.length > 0
      [first, theRest...] = actions
      Q(first.call(context))
      .then =>
        @promiseAllActions(context, theRest)
    else
      Q()

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
