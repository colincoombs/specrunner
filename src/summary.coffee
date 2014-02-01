specrunner = require('..')

class Summary

  constructor: () ->
    @passes = 0
    @pends = 0
    @fails = 0

  add: (result) ->
    switch result.kind
      when specrunner.Result.PASS
        @passes += 1
      when specrunner.Result.PEND
        @pends += 1
      when specrunner.Result.FAIL
        @fails += 1
    
  exitCode: () ->
    if @fails > 0
      return 1
    else if @pends > 0
      return 0
    else if @passes > 0
      return 0
    else
      return 0
  
module.exports = Summary
