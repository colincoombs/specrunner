specrunner = require('..')
Q          = require('q')

class Main

  @trace: false
  
  constructor: (@db, @options = {}) ->
    console.log 'Main#constructor' if Main.trace
    @formatter = new specrunner.Formatter() if @options.format?
    @summary = new specrunner.Summary()
    
  run: (args...) ->
    console.log 'Main#run', args if Main.trace
    @promiseToRun(args)
    .then =>
      console.log 'Main#run completed' if Main.trace
      @formatter?.summary(@summary)
      Q(@summary.exitCode())
      
  promiseToRun: (filenames) ->
    console.log 'Main#promiseToRun', filenames.length if Main.trace
    Q(
      if (filenames.length > 0)
        [first, theRest...] = filenames
        @runOneFile(first)
        .then =>
          @promiseToRun(theRest)
    )
      
  runOneFile: (filename) ->
    console.log 'Main#runOneFile', filename if Main.trace
    spec = new specrunner.Spec(filename)
    spec.toplevel.addFormatter(@formatter) if @formatter
    spec.run(@db)
    .then =>
      Q(spec.toplevel.summarizeTo(@summary))
  
module.exports = Main
