specrunner = require('..')
fs         = require('fs')
Q          = require('q')
child_process = require('child_process')

# array pin# -> port, bit
Uno =
  pins: [
    { port: 'D', bit: 0 }
    { port: 'D', bit: 1 }
    { port: 'D', bit: 2 }
    { port: 'D', bit: 3 }
    { port: 'D', bit: 4 }
    { port: 'D', bit: 5 }
    { port: 'D', bit: 6 }
    { port: 'D', bit: 7 }
    { port: 'B', bit: 0 }
    { port: 'B', bit: 1 }
    { port: 'B', bit: 2 }
    { port: 'B', bit: 3 }
    { port: 'B', bit: 4 }
    { port: 'B', bit: 5 }
  ]

class FileWriter

  lines: []
    
  dent: ''
  
  stream: null
  
  constructor: (@fileName) ->
    #@stream = fs.createWriteStream(fileName)
    
  write: ->
    @start()
    @body()
    @end()

  start: ->
    @lines = []
    @dent = ''
    
  body: ->
    throw new Error('SubclassResponsibility')
  
  end: ->
    fs.writeFileSync(@fileName, @lines.join('\n'))
    #@stream.write "#{l}\n" for l in @lines
    #@stream.end()
    
  l: (args...) ->
    for text in args
      if text.match /^}/
        @outdent()
      @lines.push "#{@dent}#{text}"
      if text.match /{$/
        @indent()
  
  indent: ->
    @dent += '  '
  
  outdent: ->
    @dent = @dent[2...]

class SystemHwH extends FileWriter

  # pins:
  #   name:
  #     port: 'B'
  #     bit: 4
  #
  constructor: (@pins, fileName) ->
    super(fileName)

  body: ->
    #console.log 'SystemHwH#body', @pins
    @l(
      '#ifndef __SYSTEM_HW_H'
      '#define __SYSTEM_HW_H'
      ''
      '#ifdef TARGET'
    )
    for name, pin of @pins
      #console.log 'SystemHwH#body found', name, pin
      n = name.toUpperCase()
      @l(
        "#define #{n}_1 PORT#{pin.port} |= _BV(PORT#{pin.port}#{pin.bit})"
        "#define #{n}_0 PORT#{pin.port} &= ~_BV(PORT#{pin.port}#{pin.bit})"
      )
    @l(
      '#endif'
      ''
      '#endif'
    )

class SystemSwH extends FileWriter

  # agents:
  #   name:
  #     {}
  #
  constructor: (@agents, fileName) ->
    #console.log 'SystemSwH#constructor', @agents
    super(fileName)

  body: ->
    @l(
      '#ifndef __SYSTEM_SW_H'
      '#define __SYSTEM_SW_H'
      ''
      '#define MESSAGE_SIZE 8'
      '#define N_MESSAGES 8'
      ''
    )
    i = 16
    for n of @agents
      @l "#define #{n.toUpperCase()}_MESSAGE_BASE #{i}"
      i += 16
    @l(
      ''
      '#endif'
    )
    
class SystemC extends FileWriter

  constructor: (@agents, fileName) ->
    console.log 'SystemC#constructor', @agents
    super(fileName)
    
  body: ->
    @l(
      '#include <system.h>'
      '#include <ak.h>'
      '#include <avr/io.h>'
      ''
      '/* static data for each agent */'
      ''
    )
    for n, a of @agents
      a.init ?= [[]]
      @l "#include <#{n}.h>"
      @l "static #{n}_t #{n}[#{a.init.length}];"
    @l(
      ''
      '/* table of all agents */'
      ''
      'ak_agent_t *agents[] = {'
    )
    for n,a of @agents
      @l "(ak_agent_t *)&#{n}[#{i}]," for i in [0...a.init.length]
    @l(
      '(ak_agent_t *)0'
      '};'
      ''
      '/* message buffer pool */'
      ''
      'uint8_t pool[N_MESSAGES*MESSAGE_SIZE];'
      ''
      '/* start the system running */'
      ''
      'void main(void) {'
      'DDRB = 0xEF;'
      'PORTB = 0;'
      'ak_system_init(pool, N_MESSAGES, MESSAGE_SIZE);'
      ''
    )
    for n, a of @agents
      for init, i in a.init
        args = (a for a in init)
        args.unshift "&#{n}[#{i}]"
        @l "#{n}_init(#{args.join(', ')});"
    @l(
      ''
      'ak_system_start(agents, sizeof(agents)/sizeof(agents[0])-1);'
      ''
      'ak_system_run();'
      '}'
    )

class SystemV extends FileWriter

  constructor: (@target,@stimuli,@responses,@runtime, fileName) ->
    super(fileName)
    

  body: ->
    @l(
      '`timescale 1ns / 1ns'
      'module test;'
      ''
    )
    @l "  reg #{n};"  for n of @stimuli
    @l "  wire #{n};" for n of @responses
    @l(
      '  wire[19:0] pins;'
      "  Uno #(\"#{@target}.elf\") uno(pins);"
    )
    @l "  assign pins[#{v.pin}] = #{n};" for n, v of @stimuli
    @l "  assign #{n} = pins[#{v.pin}];" for n, v of @responses
    @l(
      '  initial begin'
      "    $dumpfile(\"#{@target}.vcd\")"
      '    $dumpvars(0,test);'
      '  end'
    )
    for n, s of @stimuli
      @l '  initial begin'
      t = 0
      for ev in s.events
        [d, v] = ev
        d -= t
        @l "    ##{d} #{n} <= #{v};"
        t += d
      @l '  end'
    @l(
      '  initial begin'
      "    ##{@runtime} $finish;"
      '  end'
      'endmodule'
    )
    
# actually run a target program
#
class Observation extends specrunner.Context

  @trace: false

  constructor: (example, @db) ->
    console.log 'Observation#constructor', @db if Observation.trace
    super(example)
    @rundata = {}
    @flag = 'Woof!'
  
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
  
  hardware: (options) ->
    console.log 'Observation#hardware', options if Observation.trace
    @rundata.stimuli = {}
    @rundata.responses = {}
    # get the pins used in this configuration
    @rundata.stimuli[n] = v for n, v of options.stimuli
    @rundata.responses[n] = v for n, v of options.responses
    #console.log 'PINS', @pins
    # annotate pins with port/bit details
    #console.log 'UNO', Uno
    for n,p of @rundata.responses
      #console.log 'PIN', n, p
      p.port = Uno.pins[p.pin].port
      p.bit  = Uno.pins[p.pin].bit
    #console.log 'PINS', @pins
    new SystemHwH(@rundata.responses, 'system_hw.h').write()
    @promiseToRun( '/usr/bin/make', [ "kernel" ] )
    
  firmware: (options) ->
    console.log 'Observation#firmware', options if Observation.trace
    # define agents
    @agents = {}
    for n,v of options.system
      #console.log 'Observation#firmware found', n, v
      @agents[n] = v
    new SystemSwH(@agents, 'system_sw.h').write()
    new SystemC(@agents, 'system.c').write()
    @promiseToRun( '/usr/bin/make', [ "elf" ] )
    
  stimuli: (options) ->
    console.log 'Observation#stimuli', options if Observation.trace
    for n,v of options.stimuli
      @rundata.stimuli[n].events = v
    @rundata.runtime = options.runtime
    new SystemV(
      'responder',
      @rundata.stimuli,
      @rundata.responses,
      @rundata.runtime,
      'system.v'
    ).write()
    console.log 'request metadata' if Observation.trace
    @db.get(['_metadata'])
    .catch( (err) -> console.log 'AW SHUCKS', err)
    .then( (json) =>
      console.log 'got metadata', json if Observation.trace
      metadata = JSON.parse(json)
      
      if metadata.wires?
        Q()
      else
        metadata.wires = (n for n of @rundata.responses)
        metadata.wires.push n for n of @rundata.stimuli
        @db.put(['_metadata'], JSON.stringify(metadata))
        .then( => @db.addWires(metadata.wires))
    ).then( =>
      @promiseToRun(
        '/usr/bin/iverilog'
        [
          "#{@target}.v",
          #"-v",
          "-y#{@vlibdir}",
          "-I.",
          "-o", "#{@target}.vvp"
        ]
      )
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
      console.log 'Observation: Vcd#run' if Observation.trace
      new specrunner.Vcd(@db, "#{@target}.vcd").run()
    ).then( =>
      console.log 'Observation: Vcd#ran' if Observation.trace
    )

  # fixed settings for now, decide how to set them later...
  #
  target: 'responder'
  mode: 'simulated'    # the only choice just now

  # the test inputs
  #
  # output lines to record
  #

  # odds and sods
  #
  timescale:
    ns: 1
  timeFactor: 1/1000
  runtime: 2400000
  vlibdir: "/mnt/projects/arduino/verilog"


module.exports = Observation
