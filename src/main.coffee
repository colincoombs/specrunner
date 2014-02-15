specrunner = require('..')

class Main

  @trace: false
  
  #@run: (options) ->
  #  theInstance = new Main(options)
  #  theInstance.run(options.args)

  constructor: (@options = {}) ->
    console.log 'Main#constructor' if Main.trace
    @formatter = new specrunner.Formatter() if @options.format?
    @summary = new specrunner.Summary()
    
  run: (args...) ->
    console.log 'Main#run' if Main.trace
    for arg in args
      console.log 'try', arg
      spec = new specrunner.Spec(arg)
      spec.toplevel.addFormatter(@formatter) if @formatter
      spec.toplevel.run().done()
      spec.toplevel.summarizeTo(@summary)
      spec.toplevel.formatSummary(@summary)
    return @summary.exitCode()

module.exports = Main
