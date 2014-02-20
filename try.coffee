specrunner = require('../specrunner')

location = './db.sqlite'

#specrunner.Observation.trace = true
#specrunner.Vcd.trace = true

specrunner.Database.open(location, prefix: ['responder'])
.then( (db) -> new specrunner.Observation(db).run() )
.then( -> process.exit(0) )
.done()



