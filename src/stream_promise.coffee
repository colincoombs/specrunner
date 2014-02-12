stream = require('stream')
Q = require('q')

class StreamPromise extends stream.Transform

  @new: (stream, action, options) ->
    q = Q.defer()
    stream.pipe(new StreamPromise(q, action, options))
    return q.promise
    
  constructor: (@q, @action, options = {}) ->
    options.objectMode = true
    super(options)
    @resolution = null
  
  _transform: (item, _, done) ->
    @action.call this, item
    done()
  
  _flush: (done) ->
    done()
    @q.resolve(@resolution)

module.exports = StreamPromise