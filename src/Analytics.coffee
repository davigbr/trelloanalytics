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
        output.global = intervals.calculate lists, cards

        for combination in labelCombinations
            filter.labelIds = combination
            labelFilteredCards = extractor.extractCards filter
            listsAndCards = intervals.calculate lists, labelFilteredCards
            combinationStr = combination.toString()
            combinationStr = 'no-labels' if combinationStr is ''
            name = ''
            labels = extractor.extractLabelsByIds combination
            for label in labels
                if name isnt ''
                    name += ' | ' + label.name 
                else
                    name += label.name

            output.labelFiltered[combinationStr] = 
                name: name
                labels: labels
                lists: listsAndCards.lists
                cards: listsAndCards.cards

        return output

module.exports = Analytics