Extractor = require './Extractor'
Intervals = require './Intervals'
math = require 'mathjs'

class Analytics
    # Takes data from a Trello board from TrelloFetcher and returns and 
    # object containing lists and cards with processed times
    process: (data, filter = {}, meta = {}) -> 

        now = new Date()
        intervals = new Intervals now, meta
        extractor = new Extractor data, meta

        labelCombinations = extractor.extractLabelCombinations()
        
        states = 
            open: true
            inProgress: true
            completed: false

        lists = extractor.extractLists(states)

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
            name = ''
            if combinationStr is ''
                combinationStr = 'no-labels' 
                name = 'No Labels'
            else
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