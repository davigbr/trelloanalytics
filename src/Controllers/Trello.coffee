class Trello

    authorized: (req, res) ->
        req.session.trelloToken = req.params.token
        res.redirect '/boards/list'

    @setup: (app) ->
        app.get '/trello/auth/', (req, res) ->
            res.render 'Trello/auth'

        app.get '/trello/authorized/:token', (req, res) ->
            (new Trello).authorized req, res


module.exports = Trello
