specrunner = require('..')

class Wire

  constructor: (@db, @name) ->
    @posedge = new specrunner.Event(this, '1')
    @negedge = new specrunner.Event(this, '0')
  
  # @param [Integer?] start
  # @param [Integer?] end
  # @return [stream.Readable]
  #
  stream: (start, end) ->
    @db.stream(
      start: @startPrefix(start)
      end:   @endPrefix(end)
    )
  
  startPrefix: (start) ->
    result = [@name]
    result.push(if start? then @db.timeToStamp(start) else '')
    return result
  
  endPrefix: (end) ->
    result = [@name]
    result.push(if end? then @db.timeToStamp(end) else '~')
    return result
  
  put: (time, value) ->
    console.log 'Wire#put', @name, time, value
    @db.put([@name, @db.timeToStamp(time)], value)
    
  plotValue: (value) ->
    (switch value
      when '0' then 0
      when '1' then @height
      else          @height / 2
    ) + @offset
  
module.exports = Wire
