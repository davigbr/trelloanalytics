# Extracts and filter some specific data from a Trello board data
class Extractor
    constructor: (@data) ->

    findCardActions: (cardId, allowedTypes = ['createCard', 'updateCard']) ->
        cardActions = []

        for boardAction in @data.actions
            actionType = boardAction.type

            if actionType in allowedTypes and boardAction.data.card.id is cardId
                cardActions.push boardAction

        cardActions.reverse()
        cardActions

    extractLabelsByIds: (ids) ->
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

    extractLists: ->
        listsById = {}
        for list in @data.lists
            listsById[list.id] = list
        listsById

    extractCards: (filter = {
            cardIds: false
            labelIds: false 
            onlyAfterDate: false
            onlyBeforeDate: false
            includeArchivedCards: false
        }) ->
        cardsById = {}
        for card in @data.cards

            card.actions = @findCardActions card.id
            if !filter.cardIds or card.id in filter.cardIds

                # If filtering by label is checked, test if the card contains all specified labels
                if !filter.labelIds or (filter.labelIds.every (element) -> element in card.idLabels)
                    cardsById[card.id] = card
        cardsById

module.exports = Extractor