Extractor = require './Extractor'
Intervals = require './Intervals'
MetaDataReader = require './MetaDataReader'
math = require 'mathjs'

class Analytics

    autoDetectMetaData: (lists) ->
        console.log lists

    # Takes data from a Trello board from TrelloFetcher and returns and
    # object containing lists and cards with processed times
    process: (data, filter = {}) ->

        metaDataReader = new MetaDataReader()
        listMeta = metaDataReader.readListMeta data.lists

        now = new Date()
        intervals = new Intervals now, listMeta
        extractor = new Extractor data, listMeta

        labelCombinations = extractor.extractLabelCombinations()

        states =
            open: true
            inProgress: true
            completed: false

        lists = extractor.extractLists states

        output =
            data: {}
            labelFiltered: {}

        filter.labelIds = false
        cards = extractor.extractCards filter
        output.global = intervals.calculate lists, cards
        output.labels = extractor.extractLabelsById()

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
                labels = extractor.extractLabelsWithIds combination
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
                flow: listsAndCards.flow

        filter.labelIds = false
        filter.state = 'in-progress'
        inProgressCards = extractor.extractCards filter
        output.inProgress = intervals.calculate lists, inProgressCards
        return output

module.exports = Analytics
