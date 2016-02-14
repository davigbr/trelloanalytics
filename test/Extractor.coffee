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

    describe 'extractLabelCombinations()', ->

        it 'should return all combinations of labels present in the passed cards', ->
            data = 
                actions: []
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: ['1', '2'], name: 'Another Story', closed: false }
                    { id: '3', idLabels: ['3'], name: 'Sad Story', closed: false }
                    { id: '4', idLabels: ['2'], name: 'Happy Story', closed: false }
                    { id: '5', idLabels: [], name: 'Mad Story', closed: false }
                    { id: '6', idLabels: ['2'], name: 'Great Story', closed: false }
                ]
            extractor = new Extractor data
            combinations = extractor.extractLabelCombinations()
            expect(combinations).to.eql [
                [],
                ['1', '2'],
                ['3'],
                ['2']
            ]

    describe 'extractCards()', ->

        it 'should return all cards by id if no filtering is specified', ->
            data = 
                actions: []
                cards: [
                    { id: '1', name: 'A Story', closed: false },
                    { id: '2', name: 'Another Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards()
            expect(Object.keys(cards).length).to.be 2
            expect(cards['1'].name).to.be 'A Story'
            expect(cards['2'].name).to.be 'Another Story'

        it 'should return only the cards with the specified ids if card ids are passed as filter', ->
            data = 
                actions: []
                cards: [
                    { id: '1', name: 'A Story', closed: false }
                    { id: '2', name: 'Another Story', closed: false }
                    { id: '3', name: 'Sad Story', closed: false }
                    { id: '4', name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards(cardIds: ['3', '2'])
            expect(Object.keys(cards).length).to.be 2
            expect(cards['2'].name).to.be 'Another Story'
            expect(cards['3'].name).to.be 'Sad Story'

        it 'should return only the cards containing all specified labels if label ids are passed as filter', ->
            data = 
                actions: []
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: ['1', '2'], name: 'Another Story', closed: false }
                    { id: '3', idLabels: ['3'], name: 'Sad Story', closed: false }
                    { id: '4', idLabels: ['2'], name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards(labelIds: ['1', '2'])
            expect(Object.keys(cards).length).to.be 1
            expect(cards['2'].name).to.be 'Another Story'
