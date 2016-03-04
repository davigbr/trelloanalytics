moment = require 'moment'

# Extracts and filter some specific data from a Trello board data
class Extractor
    constructor: (@data, @meta = {}) ->
        @meta.completedStateLists = [] if not Array.isArray @meta.completedStateLists

    findCardActions: (cardId) ->
        cardActions = []
        allowedTypes = ['createCard', 'updateCard']

        for boardAction in @data.actions
            actionType = boardAction.type

            if actionType in allowedTypes and boardAction.data.card.id is cardId
                cardActions.push boardAction

        cardActions.reverse()
        cardActions

    # Return all board labels in a array where the key is the label id
    extractLabelsById: ->
        labels = {}
        for label in @data.labels
            labels[label.id] = label
        labels

    # Return the labels with the specified ids
    extractLabelsWithIds: (ids) ->
        labels = []
        for label in @data.labels
            if label.id in ids
                labels.push label
        labels

    extractLabelCombinations: ->
        combinations = []

        numericArrayEquals = (arr1, arr2) ->
            if (arr1.length isnt arr2.length)
                return false
            i = arr1.length
            loop
                if arr1[i] isnt arr2[i]
                    return false;
                break if i-- is 0
            true

        for card in @data.cards
            combinationPresent = false

            for combination in combinations
                if numericArrayEquals combination, card.idLabels
                    combinationPresent = true
                    break

            if !combinationPresent
                combinations.push card.idLabels

        combinations

    extractLists: (states = {}) ->
        states.open ?= true
        states.inProgress ?= true
        states.completed ?= true

        listsById = {}

        for list in @data.lists
            isOpen = list.id in @meta.openStateLists
            isInProgress = list.id in @meta.inProgressStateLists
            isCompleted = list.id in @meta.completedStateLists

            if (states.open and isOpen) or (states.inProgress and isInProgress) or (states.completed and isCompleted)
                listsById[list.id] = list

        listsById

    extractCards: (filter = {
            cardIds: false
            labelIds: false
            onlyAfterDate: false
            onlyBeforeDate: false
            includeClosedCards: false
        }) ->
        cardsById = {}

        filter.labelIds = false if not Array.isArray filter.labelIds
        filter.cardIds = false if not Array.isArray filter.cardIds
        filter.includeClosedCards = false unless typeof filter.includeClosedCards is 'boolean'
        filter.onlyAfterDate = false unless filter.onlyAfterDate instanceof Date
        filter.onlyBeforeDate = false unless filter.onlyBeforeDate instanceof Date

        for card in @data.cards

            # Ignore cards that are not in the completed state lists specified in the meta object
            unless card.idList in @meta.completedStateLists
                continue

            card.actions = @findCardActions card.id

            if card.actions.length is 0
                card.firstActionOnBoard = new Date 0 # Unix Epoch
            else
                card.firstActionOnBoard = new Date card.actions[0].date

            # Filter cards after date
            if filter.onlyAfterDate is false or moment(card.firstActionOnBoard).isAfter filter.onlyAfterDate

                # Filte rcards before date
                if filter.onlyBeforeDate is false or moment(card.firstActionOnBoard).isBefore filter.onlyBeforeDate

                    # Filter closed cards
                    if filter.includeClosedCards is true or card.closed is false

                        # Filter cards with the specified id
                        if filter.cardIds is false or card.id in filter.cardIds

                            if filter.labelIds is false
                                cardsById[card.id] = card

                            # If filtering by label is checked, test if labelIds is an empty array and the card has no labels
                            else if filter.labelIds and filter.labelIds.length is 0
                                if card.idLabels.length is 0
                                    cardsById[card.id] = card
                                else
                                    continue
                            # If filtering by label is checked, test if the card contains all specified labels
                            else if (filter.labelIds.every (element) -> element in card.idLabels)
                                cardsById[card.id] = card
        cardsById

module.exports = Extractor
