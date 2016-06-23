# Classes
LocalStrategy = require('passport-local').Strategy;

passport =  require 'passport'

class Users

    @loginUrl: '/users/login'
    @logoutUrl: '/users/logout'
    @signupUrl: '/users/signup'

    login: (req, res) ->
        res.locals.title = 'Login'
        res.render 'Users/login'

    signupGet: (req, res) ->
        res.locals.title = 'Signup'
        res.render 'Users/signup'

    signupPost: (req, res) ->
        if true
            req.flash 'success', 'User registered successfully!'
            res.redirect '/'
        else
            req.flash 'error', 'Error'
            res.render 'Users/signup'

    logout: (req, res) ->
        req.logout()
        res.redirect Users.loginUrl

    @setupAuthentication: (app) ->
        localStrategy = new LocalStrategy passReqToCallback: true, (req, username, password, done) =>
            user = req.models['User']
            user.findByUsername username, (err, data) ->
                if err
                    return done err
                if !data or data.length is 0
                    return done null, false, message: 'Incorrect username.'
                unless user.validPassword data, password
                    return done null, false, message: 'Incorrect password.'
                done null, data
        passport.use localStrategy
        passport.serializeUser (req, user, done) ->
            done null, user.id

        passport.deserializeUser (req, id, done) ->
            user = req.models['User']
            user.findById id, (err, user) ->
                done err, user

        app.use passport.initialize()
        app.use passport.session()

        # Protects other urls if user is not authenticated
        app.use (req, res, next) ->
            authFreeUrls = ['/', Users.loginUrl, Users.logoutUrl, Users.signupUrl]
            userAuthenticated = typeof req.session.passport?.user is 'number'

            # Sends authenticated var to the view
            res.locals.authenticated = userAuthenticated

            if !userAuthenticated and req.originalUrl not in authFreeUrls
                res.redirect(Users.loginUrl)
                return

            next()

    @setup: (app) ->
        Users.setupAuthentication app

        authOptions =
            successRedirect: '/'
            failureRedirect: Users.loginUrl
            failureFlash: true

        app.post Users.loginUrl, passport.authenticate('local', authOptions)

        app.get Users.loginUrl, (req, res) -> (new Users).login req, res

        app.get Users.logoutUrl, (req, res) -> (new Users).logout req, res

        app.get Users.signupUrl, (req, res) -> (new Users).signupGet req, res

        app.post Users.signupUrl, (req, res) -> (new Users).signupPost req, res

module.exports = Users
