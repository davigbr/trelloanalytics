Model = require './Model'
crypto = require 'crypto'

class User extends Model

    constructor: ->
        super 'trelloanalytics.user'

    validPassword: (data, password) ->
        passwordHashed = crypto.createHash('md5').update(password).digest('hex')
        data.password is passwordHashed

    findById: (id, callback) ->
        sql = "SELECT * FROM #{@tableName} WHERE id = ?"
        @query sql, id: id, (err, rows) ->
            return callback(err) if err
            callback null, if rows.length is 0 then null else rows[0]

    findByUsername: (username, callback) ->
        sql = "SELECT * FROM #{@tableName} WHERE username = ?"
        @query sql, [username], (err, rows) ->
            return callback(err) if err
            callback null, if rows.length is 0 then null else rows[0]

module.exports = User
