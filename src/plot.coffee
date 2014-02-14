specrunner = require('..')
Q          = require('q')

class Plot

  # options:
  # - height
  # - timeFactor
  # - tmax
  # - yStride
  constructor: (@db, @outputStream, @options = {}) ->
    #console.log 'Plot#constructor', @db, @outputStream, @options
    # set defaults
    @options.yStride    ?= 10
    @options.height     ?= @options.yStride / 2
    @options.timeFactor ?= 1
    @options.tmax       ?= 180000
    @wireNames = @options.wireNames ? (n for n of @db.wires)
    @_computeOffsets()
    
  _computeOffsets: ->
    offset = 0
    @offsets = {}
    for n in @wireNames
      @offsets[n] = offset
      offset += @options.yStride
    @offsets._top = offset

  go: ->
    @_writeGnuplotCommands()
    return @_promiseToPipeAll(@wireNames, end:false)
    .then( =>
      @outputStream.end()
    )
    
  _writeGnuplotCommands: ->
    commands = [
      "set grid"
      "set key off"
      "set xlabel 'time (μs)'"
    ]
    commands.push @_yrangeCommand()
    commands.push @_yticsCommand()
    commands.push @_plotCommand()
    
    @outputStream.write commands.join('\n')+'\n'
    
  _yticsCommand: ->
    tics = []
    
    for label in @wireNames
      tics.push "'#{label}' #{@offsets[label]}"
  
    tics.push "'' #{@offsets._top}"
  
    return "set ytics add ( #{tics.join(',')} )"
  
  _yrangeCommand: ->
    low  = -@options.yStride/2
    high = @offsets._top
    return "set yrange [#{low}:#{high}]"

  _plotCommand: ->
    plots = []
    
    for label in @wireNames
      
      aPlot = [
        "'-'"
        "using 1:2"
        "with lines"
        "linecolor rgb 'black'"
      ]
      
      plots.push aPlot.join(' ')
    
    return "plot #{plots.join(',\\\n     ')}"
  
  _promiseToPipeAll: (wireNames, streamOptions) =>
    #console.log 'Plot#promiseToPipeAll', wireNames, streamOptions

    if wireNames.length > 0

      [first, theRest...] = wireNames
      
      @options.offset = @offsets[first]
      
      @db.wires[first].promiseToPipe(
        @outputStream
        @options
        streamOptions
      ).then( =>
        @_promiseToPipeAll(theRest, streamOptions)
      )

    else
      Q()

module.exports = Plot
