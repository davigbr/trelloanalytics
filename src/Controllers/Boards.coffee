# Dependencies
moment = require 'moment'

# Classes
TrelloFetcher = require './../TrelloFetcher'
Analytics = require './../Analytics'
Renderer = require './../Renderer'

class Boards

    appKey: 'cb7acdb2fee72c75964b52f7888feee0'

    process: (req, res) ->
        res.locals.title = 'Board Dashboard'

        boardId = req.body.id
        beforeDate = req.body.beforeDate
        afterDate = req.body.afterDate
        listId = req.body.listId

        # Token previously stored in the session
        token = req.session.trelloToken

        onlyAfterDate = moment(req.query['afterDate'], 'YYYY-MM-DD')
        onlyBeforeDate = moment(req.query['beforeDate'], 'YYYY-MM-DD')

        if onlyAfterDate.isValid()
            onlyAfterDate = onlyAfterDate.toDate()
        if onlyBeforeDate.isValid()
            onlyBeforeDate = onlyBeforeDate.toDate()

        fetcher = new TrelloFetcher @appKey, token
        fetcher.loadBoard boardId, (err, data) =>
            if err
                res.locals.error = err
                res.render 'error'
                return

            filter =
                includeClosedCards: false
                onlyAfterDate: onlyAfterDate
                onlyBeforeDate: onlyBeforeDate
                listId: listId
            analytics = new Analytics()
            processedData = analytics.process data, filter

            res.render 'Boards/dashboard',
                title: 'Trello Analytics'
                data: processedData

    # Fetch boards and list them in the user interface
    list: (req, res) ->
        res.locals.title = 'Board Processing'

        # Token previously stored in the session
        token = req.session.trelloToken

        fetcher = new TrelloFetcher @appKey, token
        fetcher.listBoards (err, data) =>
            if err
                res.locals.error = err
                console.log err
                res.render 'error'
                return
            res.locals.boards = data
            res.render 'Boards/list'

    @setup: (app) ->
        app.get '/boards/list/', (req, res) ->
            (new Boards).list req, res
        app.post '/boards/process', (req, res) ->
            (new Boards).process req, res

module.exports = Boards
