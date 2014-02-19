#level  = require('level')
Q      = require('q')
stream = require('stream')
specrunner = require('..')

class KeyStripper extends stream.Transform

  constructor: (@db, options = {}) ->
    options.objectMode = true
    super(options)
  
  _transform: (item, _, done) ->
    item.key = @db.relativeKey(item.key)
    @push(item)
    done()
    
class Database

  @_level: null
  
  @_toplevel: null
  
  @separator: '~'
  
  @trace: false
  
  @open: (location, options={}) ->
    console.log('Database.open', location, options) if Database.trace
    @getLevel(location, options)
    .then =>
      @toplevel()
    .then (toplevel) =>
      console.log('@findByPrefix...') if Database.trace
      @findByPrefix(toplevel, options.prefix, options)
    
  @getLevel: (location, options) ->
    console.log 'Database.getLevel', location, options if Database.trace
    if @_level?
      console.log 'found level' if Database.trace
      Q(@_level)
    else
      console.log 'create level', specrunner.level if Database.trace
      Q.fcall(specrunner.level, location, options)
      .then (db) =>
        console.log 'created level' if Database.trace
        @_level = db
        db.on('error', (e) -> console.error 'AARGH', e)

  @toplevel: (options) ->
    console.log('Database.toplevel', options) if Database.trace
    if @_toplevel?
      console.log('found toplevel') if Database.trace
      Q(@_toplevel)
    else
      console.log('create toplevel') if Database.trace
      @_toplevel = new Database(null, options)
      Q.invoke(@_toplevel, 'setup')

  @findByPrefix: (parent, prefix = [], options) ->
    if prefix.length is 0
      console.log('found') if Database.trace
      Q(parent)
    else
      [segment, restOfPrefix...] = prefix
      child = parent.child[segment]
      if child?
        console.log('follow down', segment) if Database.trace
        Q(@findByPrefix(child, restOfPrefix))
      else
        console.log('create segment', segment) if Database.trace
        child = new Database(parent, options)
        parent.child[segment] = child
        Q.invoke(child, 'setup')
    
  @shutdown: ->
    Q.ninvoke(@_level, 'close')

  prefix: []
    
  child: {}
    
  constructor: (@parent, options = {}) ->
    console.log('Database#constructor', options) if Database.trace
    @prefix = options.prefix
    @prefix ?= []
    @child = {}
    @wires = {}
    
  setup: ->
    console.log('Database#setup()', @prefix) if Database.trace
    @get(['_metadata'])
    .then (metadata) =>
      console.log(@prefix, 'got metadata', metadata) if Database.trace
      @metadata = JSON.parse(metadata)
    .catch (err) =>
      console.log(@prefix, 'NOT got metadata', err) if Database.trace
      if @parent?
        @metadata = @parent.metadata
        console.log(@prefix, 'parent metadata', @metadata) if Database.trace
      else
        @metadata =
          timeStampWidth: 8
          separator: Database.separator
        console.log(@prefix, 'default metadata', @metadata) if Database.trace
      @put(['_metadata'], JSON.stringify(@metadata))
    .then =>
      @addWires(@metadata.wires ? [])
      Q(this)
    
  addWires: (wireNames) ->
    console.log('Database#addWires', wireNames) if Database.trace
    @wires[n] = new specrunner.Wire(this, n) for n in wireNames
    
  fullKey: (key) ->
    fullKey = []
    fullKey.push(segment) for segment in @prefix
    fullKey.push(segment) for segment in key
    return fullKey.join(Database.separator)
  
  relativeKey: (key) ->
    relativeKey = key.split(Database.separator)
    return relativeKey[@prefix.length..].join(Database.separator)

  timeToStamp: (time) ->
    stamp = time.toString()
    while stamp.length < @metadata.timeStampWidth
      stamp = "0#{stamp}"
    return stamp
    
  stampToTime: (stamp) ->
    parseInt(stamp, 10)
    
  put: (key, value) ->
    q = Q.defer()
    console.log('Database#put', @fullKey(key), value) if Database.trace
    #Q.ninvoke(Database._level, 'put', @fullKey(key), value)
    Database._level.put(@fullKey(key), value, (err) ->
      console.log('callback', err) if Database.trace
      if err?
        console.log('reject') if Database.trace
        q.reject(err)
      else
        console.log('resolve') if Database.trace
        q.resolve()
    )
    return q.promise
  
  get: (key) ->
    console.log('Database#get', @fullKey(key)) if Database.trace
    Q.ninvoke(Database._level, 'get', @fullKey(key))
    
  del: (key) ->
    console.log('Database#del', @fullKey(key)) if Database.trace
    Database._level.del(@fullKey(key))
    
  stream: (options) ->
    console.log('Database#stream') if Database.trace
    q = Q.defer()
    sopts = {}
    sopts[k] = v for k,v of options
    sopts.start = @fullKey(sopts.start ? [])
    sopts.end = @fullKey(sopts.end ? Database.separator)
    Q.ninvoke(Database._level, 'createReadStream', sopts)
    .then ( (stream) =>
      console.log('stream callback') if Database.trace
      stream.pipe(new KeyStripper(this))
      q.resolve(stream)
    )
    return q.promise
    
module.exports = Database
