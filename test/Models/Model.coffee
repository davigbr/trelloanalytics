Model = require '../../src/Models/Model'

describe 'Model', ->

    class User extends Model
        constructor: ->
            super 'user'


    describe 'insert()', ->

        it 'should prepare the insert statement correctly', (done) ->
            user = new User
            connection =
                query: (sql, data, callback) ->
                    expect(sql).to.be 'INSERT INTO user SET ?'
                    done()

            user.setup connection
            user.insert username: 'davi', password: '123456'





