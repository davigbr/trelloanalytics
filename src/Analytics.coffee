Extractor = require './Extractor'
Intervals = require './Intervals'
math = require 'mathjs'

class Analytics
    constructor: ->
        @now = new Date()

    # Takes data from a Trello board from TrelloFetcher and returns and 
    # object containing lists and cards with processed times
    process: (data, filter = {
            cardIds: false
            onlyAfterDate: false
            onlyBeforeDate: false
            includeClosedCards: false
        }) -> 

        intervals = new Intervals @now
        extractor = new Extractor data

        labelCombinations = extractor.extractLabelCombinations()
        
        lists = extractor.extractLists()

        output = 
            data: {}
            labelFiltered: {}

        filter.labelIds = false
        cards = extractor.extractCards filter
        output.data = intervals.calculate lists, cards

        for combination in labelCombinations
            filter.labelIds = combination
            labelFilteredCards = extractor.extractCards filter
            listsAndCards = intervals.calculate lists, labelFilteredCards
            combinationStr = combination.toString()
            combinationStr = 'no-labels' if combinationStr is ''
            output.labelFiltered[combinationStr] = 
                labels: extractor.extractLabelsByIds combination
                lists: listsAndCards.lists
                cards: listsAndCards.cards

        return output

module.exports = Analytics