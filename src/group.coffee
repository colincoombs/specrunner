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
    @formatGroupStart(this) if @parent?
    for example in @examples
      @current = example
      example.run()
      @current = null
    @formatGroupEnd(this) if @parent?
    
  runAllBeforeEach: (context) ->
    if @parent?
      @parent.runAllBeforeEach(context)
    for action in @beforeEach
      action.call(context)
  
  runAllAfterEach: (context) ->
    for action in @afterEach
      action.call(context)
    if @parent?
      @parent.runAllAfterEach(context)
  
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
