express = require 'express' 
app = express()

TrelloFetcher = require './src/TrelloFetcher'
Analytics = require './src/Analytics'
Renderer = require './src/Renderer'

app.use express.static 'static'
app.use express.static 'pages'

app.get '/authorized/:token', (req, res) ->

    token = req.params.token
    appKey = 'cb7acdb2fee72c75964b52f7888feee0'
    boardId = 'BdebeREh' #'9O7SmOjz' #'lS6D7U5T'

    fetcher = new TrelloFetcher appKey, token
    fetcher.loadBoard boardId, (err, data) -> 
        return res.send(err) if err

        analytics = new Analytics()
        processedData = analytics.process data
        res.send processedData

app.listen 3000, -> 
    console.log('Example app listening on port 3000!')
