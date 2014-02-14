specrunner = require('..')

class Main

  @run: (options) ->
    theInstance = new Main(options)
    theInstance.run(options.args)

  constructor: (@options) ->
    #console.log 'Main#constructor'
    
  run: (args) ->
    #console.log 'Main#run'
    spec = new specrunner.Spec('../test_data/test.coffee')
    #spec.toplevel.addFormatter(new specrunner.Formatter())
    spec.toplevel.run()
    summary = new specrunner.Summary()
    spec.toplevel.summarizeTo(summary)
    spec.toplevel.formatSummary(summary)
    return summary.exitCode()

module.exports = Main
