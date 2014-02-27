specrunner = require('..')
path = require('path')
class Spec

  @trace: false
  
  toplevel: null
  
  current: null
  
  constructor: (@filename) ->
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
    
  run: () ->
    console.log 'Spec#run' if Spec.trace
    @toplevel?.run()
  
  hardware: (options) ->
    console.log 'Spec#hardware' if Spec.trace
    @current.addBeforeEach(
      -> @hardware(options)
    )
    
  firmware: (options) ->
    console.log 'Spec#firmware' if Spec.trace
    @current.addBeforeEach(
      -> @firmware(options)
    )
    
  stimuli: (name, options) ->
    console.log 'Spec#stimuli' if Spec.trace
    new specrunner.Example(@current, name,
      -> @stimuli(options)
    )
    
  check: (fn) ->
    console.log 'Spec#check' if Spec.trace
    @afterEach(fn)

module.exports = Spec