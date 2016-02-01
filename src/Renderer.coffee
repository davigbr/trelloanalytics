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
                        average: list.times.average
                        median: list.times.median
                        max: list.times.max
                        min: list.times.min
                        medianFormatted: numeral(list.times.median / 1000).format('00:00:00')
                        averageFormatted: numeral(list.times.average / 1000).format('00:00:00')
                        maxFormatted: numeral(list.times.max / 1000).format('00:00:00')
                        minFormatted: numeral(list.times.min / 1000).format('00:00:00')
        return output

module.exports = Renderer