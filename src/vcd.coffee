fs     = require('fs')
stream = require('stream')

class Vcd extends stream.Writable

  constructor: (@db, vcdFileName) ->
    super()
    @pending = ''
    @state = 'start'
    @scopeDepth = 0
    @map = {}
    @time = 0
    fs.createReadStream(vcdFileName)
    .pipe(this)
    .on('error', (e) -> console.error e)
    .on('finish', -> console.log 'finish')
    
  _write: (chunk, _, done) ->
    try
      #console.log "write #{chunk.length} bytes"
      [lines..., @pending] = (@pending + chunk).split(/\r?\n/)
      #console.log "that's #{lines.length} lines"
      for line in lines
        #console.log 'line', line
        switch @state
          when 'start'
            @lineInStart(line)
          when 'scope'
            @lineInScope(line)
          when 'dumpvars'
            @lineInDumpvars(line)
          else
            console.error "Vcd state #{@state} - WTF?"
      done()
    catch e
      console.error(e)
      
  lineInStart: (line) ->
    words = line.split(' ')
    switch words[0]
      when '$scope'
        @scopeDepth += 1
        @state = 'scope'
        #console.log 'wires', @db.wires
  
  lineInScope: (line) ->
    words = line.split(' ')
    switch words[0]
      when '$scope'
        @scopeDepth += 1
      when '$upscope'
        @scopeDepth -= 1
      when '$var'
        [_, _, _, short, long, _] = words
        #console.log 'consider', @scopeDepth, short, long
        if (@scopeDepth is 1) and (long of @db.wires)
          @map[short] = @db.wires[long]
          console.log 'map', short, '->', long
      when '$dumpvars'
        @state = 'dumpvars'
        #console.log 'MAP', @map

  lineInDumpvars: (line) ->
    first = line[0]
    rest = line[1..]
    #console.log 'dv', first, rest
    switch first
      when '#'
        @time = parseInt(rest)
        #console.log 'time', @time
      else
        if rest of @map
          console.log @time, rest, first
          @map[rest].put(@time, first)
          console.log 'done put'
        else
          #console.log 'ignore', rest
    #console.log 'done line'

module.exports = Vcd
