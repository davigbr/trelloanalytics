# Dependencies
express = require 'express'
session = require 'cookie-session'
flash = require 'connect-flash'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
mysql = require 'mysql'

class Server
    adresss: '0.0.0.0'
    sessionOptions:
        secret: 'my-session-secret'
        resave: false
        saveUninitialized: true
        cookie: secure: true
    defaultPort: 3000
    models: []

    loadControllers: ->
        [
          'Users', 'Trello', 'Boards', 'Home'
        ].map (controllerName) =>
          controller = require './src/Controllers/' + controllerName
          controller.setup @app

    loadModels: ->
        localOptions =
            host: '127.0.0.1',
            user: 'root',
            password: '',
            port: 3306,
            database: 'trelloanalytics'

        databaseOptions =
            process.env.JAWSDB_URL or localOptions

        console.log databaseOptions

        # Setup connection middleware
        @app.use (req, res, next) ->
            connection = mysql.createConnection databaseOptions
            connection.connect (error) ->
                if error
                    return res.send "Database error: #{error}"

                req.models = []
                ['User'].map (modelName) =>
                    modelClass = require "./src/Models/#{modelName}"
                    req.models[modelName] = new modelClass
                    req.models[modelName].setup connection
                next()

    init: ->
        @port = process.env.PORT or @defaultPort

        @app = express()
        @app.set 'view engine', 'jade'
        @app.use express.static 'static'
        @app.use cookieParser()
        @app.use bodyParser.json()
        @app.use bodyParser.urlencoded extended: false
        @app.use session @sessionOptions
        @app.use flash()

        # Passes some variables to the view
        @app.use (req, res, next) ->
            res.locals.url = req.originalUrl
            res.locals.successMessage = req.flash('success')
            res.locals.errorMessage = req.flash('error')
            next()

        @loadModels()
        @loadControllers()

        @app.listen @port, @address, =>
            console.log "Server running on port #{@port}!"

server = new Server
server.init()
