specrunner = require('..')

class Spec

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
    
  run: () ->
    @e.run()
    
module.exports = Spec