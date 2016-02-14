express = require 'express' 
moment = require 'moment'
app = express()

TrelloFetcher = require './src/TrelloFetcher'
Analytics = require './src/Analytics'
Renderer = require './src/Renderer'

app.use express.static 'static'
app.use express.static 'pages'
app.set 'view engine', 'jade'

app.set 'port', process.env.PORT or 3000

app.get '/authorized/:token', (req, res) ->

    token = req.params.token
    appKey = 'cb7acdb2fee72c75964b52f7888feee0'
    boardId = 'lS6D7U5T'
    #'BdebeREh' #'9O7SmOjz' 

    fetcher = new TrelloFetcher appKey, token
    fetcher.loadBoard boardId, (err, data) -> 
        return res.send(err) if err

        analytics = new Analytics()
        processedData = analytics.process data, 
            includeClosedCards: false
            #onlyAfterDate: moment().subtract(30, 'days').toDate()
            #onlyBeforeDate: moment().subtract(15, 'days').toDate()
        res.render 'index', 
            title: 'Trello Analytics'
            data: processedData

app.listen app.get('port'), -> 
    console.log 'Example app listening on port ' + app.get('port') + '!'
