dblite = require('dblite')
stream = require('stream')
Q      = require('q')

level = (location = './db.sqlite', opts={}, cb) ->
  db = new FakeLevel(location)
  if cb?
    process.nextTick(-> cb(null, db))
  return db
  
class FakeLevel

  constructor: (fileName) ->
    @db = dblite(fileName)
    @query(
      'CREATE TABLE IF NOT EXISTS stuff (key TEXT PRIMARY KEY, value TEXT)'
    )
    
  put: (key, value, cb) ->
    @query(
      "SELECT value FROM stuff WHERE key = '#{key}'"
      (err, rows) =>
        #console.log 'selection', err, rows
        if err
          throw err
        else if rows.length is 0
          #console.log 'not found'
          @query(
            "INSERT INTO stuff VALUES ('#{key}', '#{value}')"
          )
          cb(null) if cb?
        else
          #console.log 'found'
          @query(
            "UPDATE stuff SET value = '#{value}' WHERE key = '#{key}'"
          )
          cb(null) if cb?
    )
    
  get: (key, cb) ->
    #console.log 'FakeLevel#get', key
    @query(
      "SELECT value FROM stuff WHERE key = '#{key}'"
      (err, rows) ->
        #console.log 'SQLITE:', err, rows
        if err?
          result = null
        else unless rows?
          result = null
          err = new Error('entry not found')
        else unless rows.length > 0
          result = null
          err = new Error('entry not found')
        else
          result = rows[0][0]
        #console.log 'CALLBACK', err, result
        cb(err, result) if cb?
    )

  del: (key) ->
    throw new Error('TBS')
  
  createReadStream: (options = {}, cb) ->
    sql = ["SELECT * FROM stuff"]
    conditions = []
    if options.start?
      conditions.push "key >= '#{options.start}'"
    if options.end?
      conditions.push "key <= '#{options.end}'"
    if conditions.length > 0
      sql.push "WHERE"
      sql.push conditions.join(" AND ")
    sql.push "ORDER BY key"
    if options.reverse? is true
      sql.push "DESC"
    if options.limit?
      sql.push "LIMIT #{options.limit}"
    @db.query(
      sql.join(' ')
      ['key', 'value']
      (err, rows) ->
        rows ?= []
        cb(err, new ReadStream(rows))
    )
    
  close: () ->
    @db.close()

  query: (sql, args...) ->
    #console.log sql
    @db.query(sql, args...)
    
class ReadStream extends stream.Readable

  constructor: (@data, options = {}) ->
    options.objectMode = true
    super(options)
  
  _read: (_) ->
    if @data.length is 0
      #console.log 'EOF'
      @push(null)
    else
      chunk = @data.shift()
      #console.log 'READ', chunk
      @push(chunk)

module.exports = level
