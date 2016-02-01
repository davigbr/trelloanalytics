Extractor = require '../src/Extractor'

describe 'Extractor', ->

    describe 'findCardActions()', ->

        it 'should return only the actions that belong to the specified card', ->
            cardId = '123dd198d890'
            data = 
                actions: [{
                    type: 'updateCard',
                    data:
                        card: 
                            id: 'fdf98dfdj98'
                },{
                    type: 'createCard',
                    data:
                        card:
                            id: cardId    
                }]
            extractor = new Extractor data
            actions = extractor.findCardActions cardId
            expect(actions.length).to.be 1
