class Home

    home: (req, res) ->
        res.locals.title = 'Home'
        res.render 'home'

    @setup: (app) ->
        app.get '/', (req, res) -> (new Home).home req, res

module.exports = Home
