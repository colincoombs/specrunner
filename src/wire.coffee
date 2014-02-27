Q          = require('q')
stream     = require('stream')
specrunner = require('..')

class GnuplotFormatter extends stream.Transform

  constructor: (@db, @wire, @options = {}) ->
    @options.objectMode = true
    super(@options)
  
  _transform: (ev,_,done) =>
    stamp = ev.key.split('~').pop()
    t = @db.stampToTime(stamp) * @options.timeFactor
    if t isnt @t
      @_drawToTime(t)
    @v = @wire._plotValue(ev.value)
    done()

  _flush: (done) =>
    @_drawToTime(@options.tmax)
    @emit 'resolve'
    @push "e\n"
    done()

  _drawToTime: (t) ->
    # draw vertical
    @push "#{@t} #{@v}\n"
    # draw horizontal
    @t = t
    @push "#{@t} #{@v}\n"
    
class Wire

  @trace: false
  
  constructor: (@db, @name) ->
    console.log 'Wire#constructor', @db, @name if Wire.trace
    @posedge = new specrunner.Event(this, '1')
    @negedge = new specrunner.Event(this, '0')
    @t = 0
    @v = 0
  
  put: (time, value) ->
    console.log 'Wire#put', @name, time, value if Wire.trace
    @db.lastTime = time
    @db.put([@name, @db.timeToStamp(time)], value)
    
  stream: (start, end) ->
    @db.stream(
      start: @startPrefix(start)
      end:   @endPrefix(end)
    )
  
  promiseToPipe: (outputStream, @options = {}, streamOptions) =>
    console.log(
      'Wire#promiseToPipe', outputStream, options, streamOptions
    ) if Wire.trace
    @options.offset ?= 0
    @options.height ?= 5
    @options.timeFactor ?= 1
    @options.tmax ?= 100
    @q = Q.defer()
    @stream().then( (s) =>
      f = new GnuplotFormatter(@db, this, @options)
      f.on 'resolve', => @q.resolve()
      s
      .pipe(f)
      .pipe(outputStream, streamOptions)
    ).fail((err) =>
      @q.reject(err)
    )
    return @q.promise

  startPrefix: (start) ->
    result = [@name]
    result.push(if start? then @db.timeToStamp(start) else '')
    return result
  
  endPrefix: (end) ->
    result = [@name]
    result.push(if end? then @db.timeToStamp(end) else '~')
    return result
  
  _plotValue: (value) ->
    (switch value
      when '0' then 0
      when '1' then @options.height
      else          @options.height / 2
    ) + @options.offset
  
module.exports = Wire
