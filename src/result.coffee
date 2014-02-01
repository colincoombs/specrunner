specrunner = require('..')

class Result

  @PASS: 2
  @PEND: 1
  @FAIL: 0
  
  constructor: (@kind, @description) ->
    
module.exports = Result
