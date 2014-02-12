Q          = require('q')
specrunner = require('..')
stream     = require('stream')

class Event extends stream.Transform

  constructor: (@wire, @edge, options = {}) ->
    options.objectMode = true
    super(options)
  
  stream: (options) ->
    Q(
      @wire.stream(options).then( (stream) =>
        stream.pipe(this)
      )
    )
  
  _transform: (event, _, done) ->
    if event.value is @edge
      @push(event)
    done()
    
module.exports = Event
