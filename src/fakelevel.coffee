dblite = require('dblite')
stream = require('stream')
Q      = require('q')

level = (location = './db.sqlite', opts={}, cb) ->
  if opts.trace?
    FakeLevel.trace = opts.trace
  db = new FakeLevel(location)
  if cb?
    process.nextTick(-> cb(null, db))
  return db
  
class FakeLevel

  @trace: false

  constructor: (fileName) ->
    console.log('FakeLevel#constructor', fileName) if FakeLevel.trace
    @db = dblite(fileName)
    @query(
      'CREATE TABLE IF NOT EXISTS stuff (key TEXT PRIMARY KEY, value TEXT)'
    )
    
  put: (key, value, cb) ->
    console.log('FakeLevel#put', key, value) if FakeLevel.trace
    @query(
      "SELECT value FROM stuff WHERE key = '#{key}'"
      (err, rows) =>
        console.log 'selection', err, rows
        if err
          throw err
        else if rows.length is 0
          console.log 'not found'
          @query(
            "INSERT INTO stuff VALUES ('#{key}', '#{value}')"
          )
          cb(null) if cb?
        else
          console.log 'found'
          @query(
            "UPDATE stuff SET value = '#{value}' WHERE key = '#{key}'"
          )
          cb(null) if cb?
    )
      
  get: (key, cb) ->
    console.log('FakeLevel#get', key) if FakeLevel.trace
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
    console.log('FakeLevel#del', key) if FakeLevel.trace
    throw new Error('TBS')
  
  createReadStream: (options = {}, cb) ->
    console.log('FakeLevel#craeteReadStream', options) if FakeLevel.trace
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
    console.log('FakeLevel#close') if FakeLevel.trace
    @db.close()

  query: (sql, cb) ->
    console.log('SQL', sql) if FakeLevel.trace
    @db.query(sql, cb)
    
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
