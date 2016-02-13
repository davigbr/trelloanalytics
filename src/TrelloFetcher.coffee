Trello = require 'node-trello'
fs = require 'fs'

class TrelloFetcher
    constructor: (appKey, token) ->
        @trello = new Trello appKey, token

    # Remove unwanted properties from board
    cleanBoard: (board) -> id: board.id, name: board.name

    # Remove unwanted properties from actions
    cleanActions: (actions) ->
        cleanedActions = []
        for action in actions
            cleanedAction = 
                id: action.id
                type: action.type
                date: action.date

            if action.data
                cleanedAction.data = {} 

                if action.data.list
                    cleanedAction.data.list = action.data.list
                if action.data.listAfter
                    cleanedAction.data.listAfter = action.data.listAfter
                if action.data.listBefore
                    cleanedAction.data.listBefore = action.data.listBefore
                if action.data.board
                    cleanedAction.data.board = 
                        id: action.data.board.id 
                if action.data.card
                    cleanedAction.data.card = 
                        id: action.data.card.id

            cleanedActions.push cleanedAction
        return cleanedActions

    # Remove unwanted properties from lists
    cleanLists: (lists) ->
        return lists

    # Remove unwanted properties from cards
    cleanCards: (cards) ->
        cleanedCards = []
        for card in cards
            cleanedCards.push 
                id: card.id
                name: card.name
                closed: card.closed
        cleanedCards

    # Fetch a trello board with some related information, like cards, actions and lists
    loadBoard: (boardId, callback) ->
        @trello.get "/1/board/#{boardId}", (err, board) =>
            return callback(err) if err 

            @trello.get "/1/board/#{boardId}/actions?limit=1000", (err, actions) =>
                return callback(err) if err 

                @trello.get "/1/board/#{boardId}/lists", (err, lists) =>
                    return callback(err) if err 

                    @trello.get "/1/board/#{boardId}/lists/closed", (err, closedLists) =>
                        return callback(err) if err 

                        @trello.get "/1/board/#{boardId}/cards", (err, cards) =>
                            return callback(err) if err 

                            allLists = lists.concat closedLists
                            output = 
                                board: @cleanBoard board
                                actions: @cleanActions actions
                                lists: @cleanLists allLists
                                cards: @cleanCards cards
                            
                            fs.writeFileSync 'tmp/data.json', JSON.stringify output, null, 4
                            
                            callback null, output

module.exports = TrelloFetcher