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

        intervals = new Intervals(new Date());

        it 'should return an empty object if there are no lists', ->
            extractor = new Extractor readDataFile 'empty-board'
            output = intervals.calculate extractor.extractLists(), extractor.extractCards()
            expect(output.lists).to.be.empty()

        it 'should return all lists with zeroed times if there are no actions, just lists', ->
            extractor = new Extractor readDataFile 'just-lists-no-actions'
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

        it 'should calculate the list times correctly', ->
            extractor = new Extractor readDataFile 'few-actions'
            output = intervals.calculate extractor.extractLists(), extractor.extractCards()
            todo = output.lists[todoId]
            doing = output.lists[doingId]

            expect(todo.times.sum).to.be 12733
            expect(todo.times.count).to.be 2
            expect(todo.times.mean).to.be 6366.5
            expect(todo.times.median).to.be 6366.5
            expect(todo.times.max).to.be 6981
            expect(todo.times.min).to.be 5752
            expect(todo.times.values).to.eql [6981, 5752]

            expect(doing.times.sum).to.be 19259
            expect(doing.times.count).to.be 2
            expect(doing.times.mean).to.be 9629.5
            expect(doing.times.median).to.be 9629.5
            expect(doing.times.max).to.be 10514
            expect(doing.times.min).to.be 8745
            expect(doing.times.values).to.eql [10514, 8745]

        it 'should calculate the card times correctly', ->
            extractor = new Extractor readDataFile 'few-actions'
            output = intervals.calculate extractor.extractLists(), extractor.extractCards()
            aStoryCard = output.cards[aStoryCardId]
            anotherStoryCard = output.cards[anotherStoryCardId]
            
            expect(aStoryCard.times[todoId]).to.be 6981
            expect(aStoryCard.times[doingId]).to.be 10514
            expect(anotherStoryCard.times[todoId]).to.be 5752
            expect(anotherStoryCard.times[doingId]).to.be 8745


