specrunner = require('..')

class Result

  @PASS: 2
  @PEND: 1
  @FAIL: 0
  
  constructor: (@kind, @description) ->
    
  @pass: (description) ->
    new Result(@PASS, description)
    
  @fail: (description) ->
    new Result(@FAIL, description)
    
  @pend: (description) ->
    new Result(@PEND, description)
    
module.exports = Result
