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
        return cardActions

    getListsById: ->
        listsById = {}
        for list in @data.lists
            listsById[list.id] = list
        return listsById
        
    getCardsById: ->
        cardsById = {}
        for card in @data.cards
            cardsById[card.id] = card
        return cardsById
        


module.exports = Extractor