specrunner = require('..')

class Group extends specrunner.Example

  constructor: (parent, name) ->
    super(parent, name)
    @examples   = []
    @before     = []
    @after      = []
    @beforeEach = null
    @afterEach  = null
    @current    = null
  
  add: (child) ->
    @examples.push(child)
  
  run: () ->
    @formatGroupStart(this)
    # do before
    for example in @examples
      @current = example
      example.run()
      @current = null
    @formatGroupEnd(this)
    
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
