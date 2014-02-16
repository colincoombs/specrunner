specrunner = require('..')
fs         = require('fs')
Q          = require('q')
child_process = require('child_process')


# actually run a target program
#
class Observation

  @trace: true
  
  # fixed settings for now, decide how to set them later...
  #
  target: 'responder'
  mode: 'simulated'    # the only choice just now

  # the test inputs
  #
  stimuli:
    int:
      pin: 12
      events: [
        [0, "1'b0"]
        [120000, "1'b1"]
      ]
  # output lines to record
  #
  responses:
    active:
      pin: 8
    agent:
      pin: 9
    isr:
      pin: 10
    led:
      pin: 11

  # odds and sods
  #
  timescale:
    ns: 1
  timeFactor: 1/1000
  runtime: 180000
  vlibdir: "/mnt/projects/arduino/verilog"


  constructor: ->
    
  writeWrapper: ->
    @stream.write s for s in [
      "`timescale 1ns / 1ns\n"
      "module test;\n"
    ]
    @declareStimuli()
    @declareResponses()
    @stream.write s for s in [
      "  wire[19:0] pins;\n"
      "  Uno #(\"#{@target}.elf\") uno(pins);\n"
    ]
    @assignStimuli()
    @assignResponses()
    @stream.write s for s in [
      "  initial begin\n"
      "    $dumpfile(\"#{@target}.vcd\");\n"
      "    $dumpvars(0,test);\n"
      "  end\n"
    ]
    @applyStimuli()
    @applyStoptime()
    @stream.write s for s in [
      "endmodule\n"
    ]

  declareStimuli: ->
    for name of @stimuli
      @stream.write "  reg #{name};\n"
    
  declareResponses: ->
    for name of @responses
      @stream.write "  wire #{name};\n"
    
  assignStimuli: ->
    for name, v of @stimuli
      @stream.write "  assign pins[#{v.pin}] = #{name};\n"
    
  applyStimuli: () ->
    for name of @stimuli
      @applyStimulus(name)
  
  applyStimulus: (name) ->
    @stream.write "  initial begin\n"
    t = 0
    for ev in @stimuli[name].events
      [delay, newvalue] = ev
      delay -= t
      @stream.write "    ##{delay} #{name} <= #{newvalue};\n"
      t += delay
    @stream.write "  end\n"

  assignResponses: ->
    for name, v of @responses
      @stream.write "  assign #{name} = pins[#{v.pin}];\n"

  applyStoptime: () ->
    @stream.write s for s in [
      "  initial begin\n"
      "    ##{@runtime} $finish;\n"
      "  end\n"
    ]

  run: ->
    @stream = fs.createWriteStream("#{@target}.v")
    @writeWrapper()
    console.log 'Observation#run' if Observation.trace
    @promiseToRun(
      '/usr/bin/iverilog'
      [
        "#{@target}.v",
        #"-v",
        "-y#{@vlibdir}",
        "-I.",
        "-o", "#{@target}.vvp"
      ]
    ).then( =>
      @promiseToRun(
        '/usr/bin/vvp',
        [
          "-M/usr/local/lib/ivl",
          "-mavr",
          "#{@target}.vvp"
        ]
      )
    ).then( =>
      console.log 'Observation#ran'
      Q()
    )
    # then import vcd to database

  promiseToRun: (prog, args) ->
    console.log 'Observation#promiseToRun', prog, args if Observation.trace
    q = Q.defer()
    child = child_process.spawn(prog, args)
    child.stdout.pipe process.stdout
    child.stderr.pipe process.stderr
    child.on 'exit', (code) ->
      console.log 'exit from child', code if Observation.trace
      q.resolve()
    child.on 'error', (err) ->
      console.log 'error from child', err if Observation.trace
      q.reject(err)
    return q.promise
  
module.exports = Observation