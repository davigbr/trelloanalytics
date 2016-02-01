Trello = require 'node-trello'

class TrelloFetcher
    constructor: (appKey, token) ->
        @trello = new Trello appKey, token

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
                                board: board
                                actions: actions
                                lists: allLists
                                cards: cards
                            callback null, output

module.exports = TrelloFetcher