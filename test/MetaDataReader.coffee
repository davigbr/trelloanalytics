MetaDataReader = require '../src/MetaDataReader'

describe 'MetaDataReader', ->

    describe 'readListMeta()', ->

        lists = [
            { id: '5653778d17e93e7e24cbb423', name: 'Ignored' }
            { id: '5653786f65d65d03d0081b6b', name: 'Ignored Again {I}' }
            { id: '56798aa8172854cd7a3c2cc6', name: 'Open {O}' }
            { id: '564c56c8122370159de93e46', name: 'In Progress {N}' }
            { id: '564c56c953051756426bb817', name: 'Also in progress {N}' }
            { id: '56b09c115eaeb2409784c9ab', name: 'Done {C}' }
            { id: '56af4192b26d3c92c5f94999', name: 'Done Again {C}' }
        ]

        reader = new MetaDataReader()
        meta = reader.readListMeta lists

        it 'should return all lists that contain the {C} identifier as completed', ->
            expect(meta.completedStateLists.length).to.be 2
            expect(meta.completedStateLists).to.contain '56b09c115eaeb2409784c9ab'
            expect(meta.completedStateLists).to.contain '56af4192b26d3c92c5f94999'

        it 'should return all lists that contain the {I} identifier as ignored', ->
            expect(meta.completedStateLists).not.to.contain '5653786f65d65d03d0081b6b'
            expect(meta.inProgressStateLists).not.to.contain '5653786f65d65d03d0081b6b'
            expect(meta.openStateLists).not.to.contain '5653786f65d65d03d0081b6b'

        it 'should return all lists that do not contain any identifier as ignored', ->
            expect(meta.completedStateLists).not.to.contain '5653778d17e93e7e24cbb423'
            expect(meta.inProgressStateLists).not.to.contain '5653778d17e93e7e24cbb423'
            expect(meta.openStateLists).not.to.contain '5653778d17e93e7e24cbb423'

        it 'should return all lists that contain the {N} identifier as in progress', ->
            expect(meta.inProgressStateLists).to.contain '564c56c8122370159de93e46'

        it 'should return all lists that contain the {O} identifier as open', ->
            expect(meta.openStateLists).to.contain '56798aa8172854cd7a3c2cc6'
