Promise = require 'promise'

Trello = require 'node-trello'

class TrelloFetcher
    constructor: (appKey, token) ->
        @trello = new Trello appKey, token

    # List boards for selection
    listBoards: (callback) ->
        @trello.get "/1/members/me/boards", (err, boards) =>
            return callback(err) if err
            callback null, boards

    # Remove unwanted properties from board
    cleanBoard: (board) -> id: board.id, name: board.name

    # Remove unwanted properties from labels
    cleanLabels: (labels) ->
        cleanedLabels = []
        for label in labels
            cleanedLabels.push
                id: label.id
                color: label.color
                name: label.name
        cleanedLabels

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
        cleanedLists = []
        for list in lists
            cleanedLists.push
                id: list.id
                name: list.name
                closed: list.closed
        cleanedLists

    # Remove unwanted properties from cards
    cleanCards: (cards) ->
        cleanedCards = []
        for card in cards
            cleanedCards.push
                id: card.id
                name: card.name
                closed: card.closed
                idLabels: card.idLabels
                idList: card.idList
        cleanedCards

    # Fetch a trello board with some related information, like cards, actions and lists
    loadBoard: (boardId, callback) ->

        fetchBoard = (output) =>
            new Promise (fulfill, reject) =>
                @trello.get "/1/board/#{boardId}", (err, board) =>
                    return reject(err) if err
                    output.board = board
                    fulfill output

        fetchLabels = (output) =>
            new Promise (fulfill, reject) =>
                @trello.get "/1/board/#{boardId}/labels", (err, labels) =>
                    return reject(err) if err
                    output.labels = labels
                    fulfill output

        fetchActions = (output) =>
            new Promise (fulfill, reject) =>
                @trello.get "/1/board/#{boardId}/actions?limit=1000", (err, actions) =>
                    return reject(err) if err
                    output.actions = actions
                    fulfill output

        fetchOpenLists = (output) =>
            new Promise (fulfill, reject) =>
                @trello.get "/1/board/#{boardId}/lists", (err, openLists) =>
                    return reject(err) if err
                    output.openLists = openLists
                    fulfill output

        fetchClosedLists = (output) =>
            new Promise (fulfill, reject) =>
                @trello.get "/1/board/#{boardId}/lists/closed", (err, closedLists) =>
                    return reject(err) if err
                    output.closedLists = closedLists
                    fulfill output

        fetchCards = (output) =>
            new Promise (fulfill, reject) =>
                @trello.get "/1/board/#{boardId}/cards/all", (err, cards) =>
                    return reject(err) if err
                    output.cards = cards
                    fulfill output

        onReject = (err) ->
            callback err

        done = (output) ->
            output.lists = output.openLists.concat output.closedLists
            delete output['closedLists']
            callback null, output

        promise = fetchBoard({})
        promise = promise.then fetchLabels, onReject
        promise = promise.then fetchActions, onReject
        promise = promise.then fetchOpenLists, onReject
        promise = promise.then fetchClosedLists, onReject
        promise = promise.then fetchCards, onReject
        promise = promise.done done, onReject

module.exports = TrelloFetcher
