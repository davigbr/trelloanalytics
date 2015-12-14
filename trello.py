import requests
import json

class Trello:
    def __init__(self, key, token):
        self.token = token
        self.key = key
        return

    def get(self, action):
        text = requests.get('https://api.trello.com/1/' + action + '?key=' + self.key + '&token=' + self.token).text
        return json.loads(text)

    def fetchBoardAndActions(self, boardId):
        board = self.get('board/%s/' % (boardId))
        board['actions'] = self.get('board/%s/actions' % (boardId))
        return board

    def fetchCardsAndActions(self, boardId):
        cards = []
        cardsJSON = self.get('board/%s/cards' % (boardId))

        for cardJSON in cardsJSON:
            card = {
                'id': cardJSON['id'],
                'name': cardJSON['name'],
            }
            card = cardJSON
            print cardJSON
            card['actions'] = self.get('card/%s/actions' % card['id'])
            cards.append(card)
            print card
        return cards

    def fetchLists(self, boardId):
        return self.get('board/%s/lists' % (boardId))
