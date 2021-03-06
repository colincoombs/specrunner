specrunner = require('..')

module.exports = ->
  @describe 'woof', ->
    
    @it 'works', ->
      @expect(true)
      
    @it 'fails', ->
      @expect(false, true, 'oops')
      
    @it 'aint ready for business', ->
      @pending('one day')
      
    @it 'aint even got out of bed'

  @describe 'fancy stuff', ->
  
    @beforeEach ->
      @log = ['one']
    
    @afterEach ->
      @log.push 'five'
      console.log 'LOGGED', @log
      
    @describe 'nested group', ->
      
      @beforeEach ->
        @log.push 'two'
        
      @afterEach ->
        @log.push 'four'
      
      @it 'goes once', ->
        @log.push 'three'
        @expect true
      
      @it 'goes again', ->
        @log.push 'three-and-a-bit'
        @pending 'zzzz'