fs     = require('fs')
Q      = require('q')
stream = require('stream')

class SplitToLines extends stream.Transform

  constructor: (options = {}) ->
    super(options)
    @pending = ''

  _transform: (chunk, _, done) ->
    #console.log "transform #{chunk.length} bytes"
    [lines..., @pending] = (@pending + chunk).split(/\r?\n/)
    #console.log "that's #{lines.length} lines"
    for line in lines
      @push(line)
    done()
    
class Vcd extends stream.Writable

  constructor: (@db, @vcdFileName) ->
    super()
    @state = 'start'
    @scopeDepth = 0
    @map = {}
    @time = 0
    
  run: ->
    q = Q.defer()
    fs.createReadStream(@vcdFileName)
    .pipe(new SplitToLines())
    .pipe(this)
    .on('error', (e) -> q.reject(err))
    .on('finish', -> q.resolve())
    return q.promise
    
  _write: (buf, _, done) ->
    line = buf.toString()
    #console.log 'line', line
    (
      switch @state
        when 'start'
          Q(@lineInStart(line))
        when 'scope'
          Q(@lineInScope(line))
        when 'dumpvars'
          @lineInDumpvars(line)
        else
          console.error "Vcd state #{@state} - WTF?"
    )
    .then( ->
      done()
    )
      
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
        result = Q(@time = parseInt(rest))
      else
        if rest of @map
          #console.log @time, rest, first
          result = @map[rest].put(@time, first)
        else
          result = Q()
    return result
  
module.exports = Vcd
