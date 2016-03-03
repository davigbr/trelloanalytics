# Read metadata from the board
class MetaDataReader

    readListMeta: (lists) ->
        meta =
            openStateLists: []
            inProgressStateLists: []
            completedStateLists: []

        for list in lists
            id = list.id
            name = list.name

            if name.indexOf('{C}') isnt -1
                meta.completedStateLists.push id
            else if name.indexOf('{N}') isnt -1
                meta.inProgressStateLists.push id
            else if name.indexOf('{O}') isnt -1
                meta.openStateLists.push id

        meta

module.exports = MetaDataReader
