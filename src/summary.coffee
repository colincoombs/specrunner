specrunner = require('..')

class Summary

  permissive: false
  
  constructor: (@permissive = false) ->
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
      # something failed: always bad
      return 1
    else if @pends > 0
      # something not implemented: still a kind of failure
      # unless we're in a good mood
      return if @permissive then 0 else 1
    else if @passes > 0
      # something worked, nothing failed, yay!
      return 0
    else
      # nothing happened: the whole darned specification
      # is kinda pending, then!
      return if @permissive then 0 else 1
  
module.exports = Summary
