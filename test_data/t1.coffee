specrunner = require('..')

module.exports = ->
  
  @describe 'G1', ->
    
    @beforeEach ->
      console.log '<b>'
      
    @it 'E1', ->
      console.log '<e>'
      @expect(true)
        

