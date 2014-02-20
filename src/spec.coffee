specrunner = require('..')
path = require('path')
class Spec

  @trace: false
  
  toplevel: null
  
  current: null
  
  constructor: (@filename, @db) ->
    console.log 'Spec#constructor', path.resolve(@filename) if Spec.trace
    try
      @toplevel = new specrunner.Group(null, null)
      @current = @toplevel
      m = require(path.resolve(@filename))
      m.apply(this)
    catch e
      console.log 'oops', e
      
  describe: (name, fn) =>
    console.log 'Spec#describe' if Spec.trace
    @current = new specrunner.Group(@current, name, fn)
    fn.apply(this)
    @current = @current.parent
  
  it: (name, fn) =>
    console.log 'Spec#in' if Spec.trace
    new specrunner.Example(@current, name, fn)

  beforeEach: (fn) =>
    console.log 'Spec#beforeEach' if Spec.trace
    @current.addBeforeEach(fn)
    
  afterEach: (fn) =>
    console.log 'Spec#afterEach' if Spec.trace
    @current.addAfterEach(fn)
    
  run: (@db) ->
    console.log 'Spec#run' if Spec.trace
    @toplevel?.run()
  
  hardware: (name, fn) ->
    console.log 'Spec#hardware' if Spec.trace
    @current = new specrunner.Group(@current, name, fn)
    fn.apply(this)
    @current = @current.parent
    
  firmware: (name, fn) ->
    console.log 'Spec#firmware' if Spec.trace
    @current = new specrunner.Group(@current, name, fn)
    fn.apply(this)
    @current = @current.parent
    
  stimuli: (name, fn) ->
    console.log 'Spec#stimuli' if Spec.trace
    @current = new specrunner.Group(@current, name, fn)
    fn.apply(this)
    @current = @current.parent
    
  check: (fn) ->
    console.log 'Spec#check' if Spec.trace
    @afterEach(fn)

module.exports = Spec