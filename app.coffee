express = require 'express'
moment = require 'moment'
app = express()

TrelloFetcher = require './src/TrelloFetcher'
Analytics = require './src/Analytics'
Renderer = require './src/Renderer'

appKey = 'cb7acdb2fee72c75964b52f7888feee0'

app.use express.static 'static'
app.set 'view engine', 'jade'

app.set 'port', process.env.PORT or 3000

app.get '/', (req, res) ->
    res.redirect '/auth'

app.get '/auth/', (req, res) ->
    res.render 'auth'

app.get '/board', (req, res) ->
    if req.query['id']?
        res.redirect '/auth/' + req.query['id']
    else

# Fetch boards and list them in the user interface
app.get '/authorized/board/:token/', (req, res) ->
    token = req.params.token
    boardId = req.query['id']

    # Board already selected
    if boardId
        res.redirect "/authorized/board/#{token}/#{boardId}"

    # Board not selected yet
    else
        fetcher = new TrelloFetcher appKey, token
        fetcher.listBoards (err, data) ->
            if err
                app.locals.error = err
                console.log err
                res.render 'error'
                return
            app.locals.boards = data
            res.render 'board'

app.get '/authorized/board/:token/:boardId', (req, res) ->

    token = req.params.token
    boardId = req.params.boardId

    fetcher = new TrelloFetcher appKey, token
    fetcher.loadBoard boardId, (err, data) ->
        if err
            app.locals.error = err
            res.render 'error'
            return

        filter =
            includeClosedCards: false
            #onlyAfterDate: moment().subtract(30, 'days').toDate()
            #onlyBeforeDate: moment().subtract(15, 'days').toDate()
        meta =
            openStateLists: ['5653778d17e93e7e24cbb423'] # Ready
            inProgressStateLists: [
                '564c56c8122370159de93e46', # Development
                '5653786f65d65d03d0081b6b' # Accepting
            ]
            completedStateLists: [
                '564c56c953051756426bb817', # Done
                '56b09c115eaeb2409784c9ab', # Reviewed 12/02
                '56af4192b26d3c92c5f94999', # Reviewed 19/01
                '56798aa8172854cd7a3c2cc6' # Reviewed 15/01
            ]
        analytics = new Analytics()
        processedData = analytics.process data, filter, meta
        res.render 'dashboard',
            title: 'Trello Analytics'
            data: processedData

app.listen app.get('port'), '0.0.0.0', ->
    console.log 'Example app listening on port ' + app.get('port') + '!'
