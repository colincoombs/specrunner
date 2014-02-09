level = require('level')
Q     = require('q')

class Database

  @level: null
  
  @open: (location, options={}) ->
    q = Q.defer()
    unless @level?
      level(location, options, (err,db) =>
        if err
          q.reject(err)
        else
          @level = db
          i = new Database(options)
          #console.log 'constructed', i
          q.resolve(i)
      )
    return q.promise

  prefix: []
    
  constructor: (options) ->
    #console.log 'Database#constructor', options
    @prefix = options.prefix ? []
    
  put: (key, value) ->
    Database.level.put(key, value)
    
  del: (key) ->
    Database.level.del(key)
    
  stream: (options) ->
    #console.log 'Database#stream', options, Database.level
    q = Q.defer()
    stream = Database.level.createReadStream(options)
    q.resolve(stream)
    return q.promise
    
module.exports = Database
