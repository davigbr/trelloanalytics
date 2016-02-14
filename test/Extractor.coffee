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

        it 'should return only the cards without labels if labelIds filter is passed as an empty array', ->
            data = 
                actions: []
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: ['1', '2'], name: 'Another Story', closed: false }
                    { id: '3', idLabels: ['3'], name: 'Sad Story', closed: false }
                    { id: '4', idLabels: ['2'], name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards(labelIds: [])
            expect(Object.keys(cards).length).to.be 1
            expect(cards['1'].name).to.be 'A Story'

        it 'should not return closed cards by default', ->
            data = 
                actions: []
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: [], name: 'Another Story', closed: true }
                    { id: '3', idLabels: [], name: 'Sad Story', closed: true }
                    { id: '4', idLabels: [], name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards()
            expect(Object.keys(cards).length).to.be 2
            expect(cards['1'].name).to.be 'A Story'
            expect(cards['4'].name).to.be 'Happy Story'

        it 'should include closed cards if true is passed to the filter', ->
            data = 
                actions: []
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: [], name: 'Another Story', closed: true }
                    { id: '3', idLabels: [], name: 'Sad Story', closed: true }
                    { id: '4', idLabels: [], name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards(includeClosedCards: true)
            expect(Object.keys(cards).length).to.be 4
            expect(cards['1'].name).to.be 'A Story'
            expect(cards['2'].name).to.be 'Another Story'
            expect(cards['3'].name).to.be 'Sad Story'
            expect(cards['4'].name).to.be 'Happy Story'
        
        it 'should include closed cards if true is passed to the filter', ->
            data = 
                actions: []
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: [], name: 'Another Story', closed: true }
                    { id: '3', idLabels: [], name: 'Sad Story', closed: true }
                    { id: '4', idLabels: [], name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards(includeClosedCards: true)
            expect(Object.keys(cards).length).to.be 4
            expect(cards['1'].name).to.be 'A Story'
            expect(cards['2'].name).to.be 'Another Story'
            expect(cards['3'].name).to.be 'Sad Story'
            expect(cards['4'].name).to.be 'Happy Story'

        it 'should include only cards with the first action after the specified date', ->
            data = 
                actions: [
                    { id: '1', type: 'createCard', date: '2001-01-01T00:00:00.000Z', data: card: id: '1' }
                    { id: '2', type: 'createCard', date: '2002-01-01T00:00:00.000Z', data: card: id: '2' }
                    { id: '3', type: 'createCard', date: '2003-01-01T00:00:00.000Z', data: card: id: '3' }
                    { id: '4', type: 'createCard', date: '2004-01-01T00:00:00.000Z', data: card: id: '4' }               
                ]
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: [], name: 'Another Story', closed: false }
                    { id: '3', idLabels: [], name: 'Sad Story', closed: false }
                    { id: '4', idLabels: [], name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards(onlyAfterDate: new Date '2001-01-01T00:00:00.000Z')
            expect(Object.keys(cards).length).to.be 3
            expect(cards['2'].name).to.be 'Another Story'
            expect(cards['3'].name).to.be 'Sad Story'
            expect(cards['4'].name).to.be 'Happy Story'

        it 'should include only cards with the first action before the specified date', ->
            data = 
                actions: [
                    { id: '1', type: 'createCard', date: '2001-01-01T00:00:00.000Z', data: card: id: '1' }
                    { id: '2', type: 'createCard', date: '2002-01-01T00:00:00.000Z', data: card: id: '2' }
                    { id: '3', type: 'createCard', date: '2003-01-01T00:00:00.000Z', data: card: id: '3' }
                    { id: '4', type: 'createCard', date: '2004-01-01T00:00:00.000Z', data: card: id: '4' }
                ]
                cards: [
                    { id: '1', idLabels: [], name: 'A Story', closed: false }
                    { id: '2', idLabels: [], name: 'Another Story', closed: false }
                    { id: '3', idLabels: [], name: 'Sad Story', closed: false }
                    { id: '4', idLabels: [], name: 'Happy Story', closed: false }
                ]
            extractor = new Extractor data
            cards = extractor.extractCards(onlyBeforeDate: new Date '2002-01-01T00:00:00.000Z')
            expect(Object.keys(cards).length).to.be 1
            expect(cards['1'].name).to.be 'A Story'
