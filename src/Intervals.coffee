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
            cards[cardId].flow = @calculateCardFlow lists, card

        @calculateListTimes lists, cards
        flow = @calculateListFlow lists, Object.keys(cards).length
        {
            lists: lists
            cards: cards
            flow: flow
        }

    calculateCardFlow: (lists, card) ->
        reaction = cycle = 0
        for listId, time of card.times
            isOpen = listId in @meta.openStateLists
            isInProgress = listId in @meta.inProgressStateLists
            reaction += time if isOpen
            cycle += time if isInProgress

        return reaction: reaction, lead: cycle + reaction, cycle: cycle

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

    calculateListFlow: (lists, cardCount) ->
        reaction =
            values: math.zeros(cardCount)
            sum: 0
            count: cardCount
            mean: null
            median: null
        lead =
            values: math.zeros(cardCount)
            sum: 0
            count: cardCount
            mean: null
            median: null
        cycle =
            values: math.zeros(cardCount)
            sum: 0
            count: cardCount
            mean: null
            median: null

        for listId, list of lists
            isOpen = listId in @meta.openStateLists
            isInProgress = listId in @meta.inProgressStateLists

            if isOpen or isInProgress
                lead.values = math.add(lead.values, math.matrix(list.times.values))
                lead.sum += list.times.sum

            if isOpen
                reaction.values = math.add(reaction.values, math.matrix(list.times.values))
                reaction.sum += list.times.sum
            else if isInProgress
                cycle.values = math.add(cycle.values, math.matrix(list.times.values))
                cycle.sum += list.times.sum

        reaction.values = reaction.values.toArray()
        lead.values = lead.values.toArray()
        cycle.values = cycle.values.toArray()

        if reaction.count isnt 0
            reaction.mean = reaction.sum / reaction.count
            reaction.median = math.median reaction.values
        if lead.count isnt 0
            lead.mean = lead.sum / lead.count
            lead.median = math.median lead.values
        if cycle.count isnt 0
            cycle.mean = cycle.sum / cycle.count
            cycle.median = math.median cycle.values

        return reaction: reaction, lead: lead, cycle: cycle

    # Takes all cards that their times were calculated on each list to sum and get
    # global sum, count, mean and median metric for each list
    calculateListTimes: (lists, cards) ->
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
