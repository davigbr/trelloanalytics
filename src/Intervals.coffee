math = require 'mathjs'

class Intervals
    constructor: (@now, @meta) -> 

    # Takes  card nad lists data and returns and 
    # object containing lists and cards with processed times
    calculate: (lists, cards) ->
        # Makes a copy of the passed objects
        lists = JSON.parse JSON.stringify lists
        cards = JSON.parse JSON.stringify cards

        for cardId, card of cards
            cards[cardId].times = @calculateCardTimes lists, card.actions
        @calculateListsTimes lists, cards
        return lists: lists, cards: cards

    # Takes all actions from a specific card to count the time a card remained on each list
    # Return an object containing all lists with the time spent on each
    calculateCardTimes: (lists, cardActions) ->
        listTimes = {}

        for listId of lists
            listTimes[listId] = 0

        i = 0
        for currentAction in cardActions
            currentActionDate = new Date currentAction.date

            if cardActions[i + 1]
                nextAction = cardActions[i + 1]
                nextActionDate = new Date nextAction.date
            else
                nextAction = null
                nextActionDate = @now

            timestampDifference = (nextActionDate.getTime() - currentActionDate.getTime()) / (60*60*1000)

            if currentAction.type in ['updateCard', 'createCard']
                currentList = null
                if currentAction.data.list
                    currentList = currentAction.data.list
                else 
                    currentList = currentAction.data.listAfter

                listTimes[currentList.id] += timestampDifference

            i++
        return listTimes

    calculateFlowMetrics: (lists, cardCount) ->
        openTimes = 
            values: math.zeros(cardCount, 1)
            sum: 0
            count: cardCount
        inProgressTimes = 
            values: math.zeros(cardCount, 1)
            sum: 0
            count: cardCount

        for listId, list of lists
            if listId in @meta.openStateLists
                openTimes.values = math.add(openTimes.values, list.times.values)
                openTimes.sum += list.times.sum
                openTimes.count = list.times.count
            if listId in @meta.inProgressStateLists
                inProgressTimes.values = math.add(inProgressTimes.values, list.times.values)
                inProgressTimes.sum += list.times.sum
                inProgressTimes.count = list.times.count

        if openTimes.count isnt 0
            openTimes.mean = openTimes.sum / openTimes.count
            openTimes.median = math.median openTimes.values
        if inProgressTimes.count isnt 0
            inProgressTimes.mean = inProgressTimes.sum / inProgressTimes.count
            inProgressTimes.median = math.median inProgressTimes.values

        return 


    # Takes all cards that their times were calculated on each list to sum and get 
    # global sum, count, mean and median metric for each list
    calculateListsTimes: (lists, cards) ->
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

module.exports = Intervals