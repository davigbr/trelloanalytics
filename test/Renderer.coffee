Renderer = require '../src/Renderer'

describe 'Renderer', ->

    describe 'renderJSON()', ->

        sampleLists = 
            '12jk3l03j': 
                name: 'Sample List'
                closed: false
                times:
                    min: 1000
                    max: 2000
                    average: 1500
                    count: 2
            'fjkd09dlkdlk':
                name: 'Closed List'
                closed: true
                times: 
                    min: 3000
                    max: 6000
                    average: 4500
                    count: 2

        instance = new Renderer sampleLists

        it 'should return an object with the list id as a key', ->
            data = instance.renderJSON()
            for key of data.lists
                expect(key).to.be.a 'string'

        it 'should not include the archived/closed lists by default', ->
            data = instance.renderJSON()
            expect(Object.keys(data.lists).length).to.be 1

        it 'should include archived/closed lists if true is passed', ->
            data = instance.renderJSON true
            expect(Object.keys(data.lists).length).to.be 2

