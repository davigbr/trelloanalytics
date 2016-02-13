numeral = require 'numeral'

class Renderer
    constructor: (@lists, @cards) ->

    renderJSON: (includeClosedLists = false) ->
        output = lists: {}
        for listId, list of @lists
            if includeClosedLists or (!list.closed and !includeClosedLists)
                output.lists[listId] = 
                    name: list.name
                    times: 
                        sum: list.times.sum
                        count: list.times.count
                        mean: list.times.mean
                        median: list.times.median
                        max: list.times.max
                        min: list.times.min
                        values: list.times.values
                        medianFormatted: numeral(list.times.median / 1000).format('00:00:00')
                        meanFormatted: numeral(list.times.mean / 1000).format('00:00:00')
                        maxFormatted: numeral(list.times.max / 1000).format('00:00:00')
                        minFormatted: numeral(list.times.min / 1000).format('00:00:00')
        return output

module.exports = Renderer