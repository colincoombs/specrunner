specrunner = require('..')

class Formatter

  constructor: () ->
    @dent = ''
    
  indent: () ->
    @dent = @dent + '    '
  
  outdent: () ->
    @dent = @dent[4..]
    
  summary: (summary) ->
    console.log "passed  #{summary.passes}"
    console.log "pending #{summary.pends}"
    console.log "failed  #{summary.fails}"
    
  result: (result) ->
    switch result.kind
      when specrunner.Result.PASS
        if result.description?
          console.log "#{@dent}PASS #{result.description}"
      when specrunner.Result.PEND
        if result.description?
          console.log "#{@dent}PENDING #{result.description}"
      when specrunner.Result.FAIL
        if result.description?
          console.log "#{@dent}FAIL #{result.description}"

  exampleStart: (example) ->
    console.log "#{@dent}#{example.name}"
    @indent()
  
  exampleEnd: (example) ->
    @outdent()
    
  groupStart: (group) ->
    if group.name?
      console.log "#{@dent}#{group.name}"
      @indent()
  
  groupEnd: (group) ->
    @outdent()
    
module.exports = Formatter
