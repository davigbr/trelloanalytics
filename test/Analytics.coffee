Analytics = require '../src/Analytics'
fs = require 'fs'
path = require 'path'

describe 'Analytics', ->

    readDataFile = (name) ->
        JSON.parse fs.readFileSync path.join __dirname, 'data', "#{name}.json"

    describe 'process', ->





