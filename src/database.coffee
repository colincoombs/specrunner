#level  = require('level')
Q      = require('q')
stream = require('stream')
specrunner = require('..')

level = specrunner.level

class KeyStripper extends stream.Transform

  constructor: (@db, options = {}) ->
    options.objectMode = true
    super(options)
  
  _transform: (item, _, done) ->
    item.key = @db.relativeKey(item.key)
    #item.key.split(Database.separator)
    #key = key[@db.prefix.length..]
    #item.key = key.join(Database.separator)
    @push(item)
    done()
    
class Database

  @_level: null
  
  @_toplevel: null
  
  @separator: '~'
  
  @open: (location, options={}) ->
    #console.log 'getlevel...'
    @getLevel(location, options)
    .then =>
      #console.log '@toplevel ...'
      @toplevel()
    .then (toplevel) =>
      #console.log '@findByPrefix...'
      @findByPrefix(toplevel, options.prefix, options)
    
  @getLevel: (location, options) ->
    if @_level?
      Q(@_level)
    else
      Q.fcall(level, location, options)
      .then (db) =>
        @_level = db
        db.on('error', (e) -> console.error 'AARGH', e)

  @toplevel: (options) ->
    if @_toplevel?
      #console.log 'found toplevel'
      Q(@_toplevel)
    else
      #console.log 'create toplevel'
      @_toplevel = new Database(null, options)
      Q.invoke(@_toplevel, 'setup')

  @findByPrefix: (parent, prefix = [], options) ->
    if prefix.length is 0
      #console.log 'found'
      Q(parent)
    else
      [segment, restOfPrefix...] = prefix
      child = parent.child[segment]
      if child?
        #console.log 'follow down', segment
        Q(@findByPrefix(child, restOfPrefix))
      else
        #console.log 'create segment', segment
        child = new Database(parent, options)
        parent.child[segment] = child
        Q.invoke(child, 'setup')
    
  @shutdown: ->
    Q.ninvoke(@_level, 'close')

  prefix: []
    
  child: {}
    
  constructor: (@parent, options = {}) ->
    #console.log 'Database#constructor', options
    @prefix = options.prefix
    @prefix ?= []
    @child = {}
    @wires = {}
    
  setup: ->
    #console.log 'Database#setup()', @prefix
    @get(['_metadata'])
    .then (metadata) =>
      #console.log @prefix, 'got metadata', metadata
      @metadata = JSON.parse(metadata)
      #console.log @prefix, 'own metadata', @metadata
    .catch (err) =>
      #console.log @prefix, 'NOT got metadata', err
      if @parent?
        @metadata = @parent.metadata
        #console.log @prefix, 'parent metadata', @metadata
      else
        @metadata =
          timeStampWidth: 8
          separator: Database.separator
        #console.log @prefix, 'default metadata', @metadata
        #console.log @prefix, 'stringify', JSON.stringify(@metadata)
      @put(['_metadata'], JSON.stringify(@metadata))
    .then =>
      wireNames = @metadata.wires ? []
      @wires[n] = new specrunner.Wire(this, n) for n in wireNames
      Q(this)
    
  fullKey: (key) ->
    fullKey = []
    fullKey.push(segment) for segment in @prefix
    fullKey.push(segment) for segment in key
    return fullKey.join(Database.separator)
  
  relativeKey: (key) ->
    relativeKey = key.split(Database.separator)
    return relativeKey[@prefix.length..].join(Database.separator)

  timeToStamp: (time) ->
    #console.log @metadata
    stamp = time.toString()
    while stamp.length < @metadata.timeStampWidth
      stamp = "0#{stamp}"
    return stamp
    
  stampToTime: (stamp) ->
    parseInt(stamp, 10)
    
  put: (key, value) ->
    #console.log 'Database#put', @fullKey(key), value
    Q.ninvoke(Database._level, 'put', @fullKey(key), value)
    #console.log 'put OK'
  
  get: (key) ->
    #console.log 'Database#get', @fullKey(key)
    Q.ninvoke(Database._level, 'get', @fullKey(key))
    
  del: (key) ->
    console.log 'Database#del', @fullKey(key)
    Database._level.del(@fullKey(key))
    
  stream: (options) ->
    #console.log 'Database#stream'
    q = Q.defer()
    sopts = {}
    sopts[k] = v for k,v of options
    sopts.start = @fullKey(sopts.start ? [])
    sopts.end = @fullKey(sopts.end ? Database.separator)
    Q.ninvoke(Database._level, 'createReadStream', sopts)
    .then ( (stream) =>
      #console.log 'stream callback'
      stream.pipe(new KeyStripper(this))
      q.resolve(stream)
    )
    return q.promise
    
module.exports = Database
