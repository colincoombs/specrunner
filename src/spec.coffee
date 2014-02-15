specrunner = require('..')

class Spec

  toplevel: null
  
  current: null
  
  constructor: (@filename) ->
    @toplevel = new specrunner.Group(null, null)
    @current = @toplevel
    m = require(@filename)
    m.apply(this)
    
  describe: (name, fn) =>
    @current = new specrunner.Group(@current, name, fn)
    fn.apply(this)
    @current = @current.parent
  
  it: (name, fn) =>
    new specrunner.Example(@current, name, fn)

  beforeEach: (fn) =>
    @current.addBeforeEach(fn)
    
  afterEach: (fn) =>
    @current.addAfterEach(fn)
    
  run: () ->
    @toplevel?.run()
    
module.exports = Spec