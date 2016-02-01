Extractor = require './Extractor'
math = require 'mathjs'

class Analytics
    constructor: ->
        @now = new Date()

    process: (data) -> 
        @extractor = new Extractor data
        lists = @extractor.getListsById()
        cards = @extractor.getCardsById()

        for cardId, card of cards
            cards[cardId].times = @processCardTimes lists, @extractor.findCardActions cardId

        @processListsTimes lists, cards

        return lists: lists, cards: cards

    processListsTimes: (lists, cards) ->
        listTimes = {}
        for listId, list of lists
            list.times = 
                sum: 0,
                count: 0,
                mean: 0,
                median: 0,
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

            if list.times.count is 0
                list.times.mean = 0
            else
                list.times.mean = list.times.sum / list.times.count

            list.times.median = math.median list.times.values


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



module.exports = Analytics