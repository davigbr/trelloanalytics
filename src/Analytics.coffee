Extractor = require './Extractor'
math = require 'mathjs'

class Analytics
    constructor: ->
        @now = new Date()

    # Takes data from a Trello board from TrelloFetcher and returns and 
    # object containing lists and cards with processed times
    process: (data) -> 
        @extractor = new Extractor data
        lists = @extractor.extractListsById()
        cards = @extractor.extractCardsById()

        for cardId, card of cards
            cards[cardId].times = @processCardTimes lists, @extractor.findCardActions cardId

        @processListsTimes lists, cards

        return lists: lists, cards: cards

    # Takes all actions from a specific card to count the time a card remained on each list
    # Return an object containing all lists with the time spent on each
    processCardTimes: (lists, cardActions) ->
        listTimes = {}

        for listId of lists
            listTimes[listId] = 0

        i = 0
        for currentAction in cardActions
            currentActionDate = new Date(currentAction.date)

            if cardActions[i + 1]
                nextAction = cardActions[i + 1]
                nextActionDate = new Date(nextAction.date)
            else
                nextAction = null
                nextActionDate = @now

            timestampDifference = nextActionDate.getTime() - currentActionDate.getTime()

            if currentAction.type in ['updateCard', 'createCard']
                currentList = null
                if currentAction.data.list
                    currentList = currentAction.data.list
                else 
                    currentList = currentAction.data.listAfter

                listTimes[currentList.id] += timestampDifference

            # console.log('@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
            # console.log('Card Name: ' + currentAction.data.card.name);
            # console.log('List Name: ' + currentList.name);
            # console.log('Interval: ' + numeral(timestampDifference / 1000).format('00:00:00'));
            i++
        return listTimes

    # Takes all cards that their times were calculated on each list to sum and get 
    # global sum, count, mean and median metric for each list
    processListsTimes: (lists, cards) ->
        listTimes = {}
        for listId, list of lists
            list.times = 
                sum: 0,
                count: 0,
                mean: null,
                median: null,
                max: null,
                min: null
                values: []

            for cardId, card of cards
                time = card.times[listId]

                list.times.sum += time
                list.times.values.push time
                list.times.count++

                if list.times.min is null or time > list.times.max
                    list.times.max = time

                if list.times.min is null or time < list.times.min
                    list.times.min = time

            if list.times.count isnt 0
                list.times.mean = list.times.sum / list.times.count
                list.times.median = math.median list.times.values


module.exports = Analytics