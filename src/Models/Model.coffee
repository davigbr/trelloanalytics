mysql = require 'mysql'

class Model
    constructor: (@tableName) ->

    insert: (data, callback) ->
        query = "INSERT INTO #{@tableName} SET ?";
        @connection.query query, data, (err, result) ->
            return callback(err) if err
            callback null, result.insertId

    query: (query, params, callback) ->
        @connection.query query, params, (err, data) ->
            callback err, data

    setup: (@connection) ->

module.exports = Model
