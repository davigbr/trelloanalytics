Intervals = require '../src/Intervals'
Extractor = require '../src/Extractor'
fs = require 'fs'
path = require 'path'

describe 'Intervals', ->

    readDataFile = (name) ->
        JSON.parse fs.readFileSync path.join __dirname, 'data', "#{name}.json"

    describe 'calculate()', ->

        todoId = '56bf6e598230d139680a48ce'
        doingId = '56bf6e5d41428906562f4aee'
        aStoryCardId = '56bf71a76a9516ec118adaff'
        anotherStoryCardId = '56bf71c2366119756581b166'

        meta = 
            openStateLists: ['56bf6e598230d139680a48ce']
            inProgressStateLists: ['56bf6e5d41428906562f4aee']
            completedStateLists: ['56bf6e5fad3b9f2a4daad199']
        intervals = new Intervals(new Date(), meta)

        it 'should return an empty object if there are no lists', ->
            extractor = new Extractor readDataFile('empty-board'), meta
            output = intervals.calculate extractor.extractLists(), extractor.extractCards()
            expect(output.lists).to.be.empty()

        it 'should return all lists with zeroed times if there are no actions, just lists', ->
            extractor = new Extractor readDataFile('just-lists-no-actions'), meta
            output = intervals.calculate extractor.extractLists(), extractor.extractCards()
            expect(Object.keys(output.lists).length).to.be 3

            for listId, list of output.lists
                expect(listId).to.be.a 'string'
                expect(list.name).to.be.a 'string'
                expect(list.times.sum).to.be 0
                expect(list.times.count).to.be 0
                expect(list.times.mean).to.be null
                expect(list.times.median).to.be null
                expect(list.times.max).to.be null
                expect(list.times.min).to.be null

        msInAnHr = 60 * 60 * 1000

        it 'should calculate the list times correctly', ->
            extractor = new Extractor readDataFile('few-actions'), meta
            output = intervals.calculate extractor.extractLists(), extractor.extractCards()
            todo = output.lists[todoId]
            doing = output.lists[doingId]

            expect(todo.times.sum).to.be 12733 / msInAnHr
            expect(todo.times.count).to.be 2
            expect(todo.times.mean).to.be 6366.5 / msInAnHr
            expect(todo.times.median).to.be 6366.5 / msInAnHr
            expect(todo.times.max).to.be 6981 / msInAnHr
            expect(todo.times.min).to.be 5752 / msInAnHr
            expect(todo.times.values).to.eql [6981 / msInAnHr, 5752 / msInAnHr]

            expect(doing.times.sum).to.be 0.005349722222222223
            expect(doing.times.count).to.be 2
            expect(doing.times.mean).to.be 0.0026748611111111114
            expect(doing.times.median).to.be 0.0026748611111111114
            expect(doing.times.max).to.be 10514 / msInAnHr
            expect(doing.times.min).to.be 8745 / msInAnHr
            expect(doing.times.values).to.eql [10514 / msInAnHr, 8745 / msInAnHr]

        it 'should calculate the card times correctly', ->
            extractor = new Extractor readDataFile('few-actions'), meta
            output = intervals.calculate extractor.extractLists(), extractor.extractCards()
            aStoryCard = output.cards[aStoryCardId]
            anotherStoryCard = output.cards[anotherStoryCardId]
            
            expect(aStoryCard.times[todoId]).to.be 6981 / msInAnHr
            expect(aStoryCard.times[doingId]).to.be 10514 / msInAnHr
            expect(anotherStoryCard.times[todoId]).to.be 5752 / msInAnHr
            expect(anotherStoryCard.times[doingId]).to.be 8745 / msInAnHr


