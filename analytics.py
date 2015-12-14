import time
import datetime

class Analytics:
    def __init__(self, board, cards, lists):
        self.board = board;
        self.cards = cards;
        self.lists = lists;

    def filterActions(self, actions, actionTypes, listsId):
        filtered = []
        for action in actions:
            actionType = action['type']
            isUpdateCard = actionType == 'updateCard'
            if actionTypes is not False and not(action['type'] in actionTypes):
                continue
            if isUpdateCard and not(action['data']['listAfter']['id'] in listsId):
                continue
            if isUpdateCard and not(action['data']['listBefore']['id'] in listsId):
                continue
            if isUpdateCard and action['data']['listBefore']['id'] == action['data']['listAfter']['id']:
                continue

            filtered.append(action)
        return filtered

    def sumTimes(self, card, lists): 
        listTimes = {}
        # Eventos ordenados pelo unix timestamp
        actions = card['actions']
        for action in actions:
            timestamp = time.mktime(datetime.datetime.strptime(action['date'], "%Y-%m-%dT%H:%M:%S.%fZ").timetuple())
            action['timestamp'] = timestamp
        actions.sort(key=lambda action: action['timestamp'])
        card['actions'] = actions

        for index in range(len(actions)):
            if index == 0:
                continue
            previousAction = actions[index - 1]
            currentAction = actions[index]

            if previousAction['data']['listAfter']['id'] != previousAction['data']['listBefore']['id']:
                print 'problem'

        return
        
    def process(self):
        cards = self.cards
        board = self.board
        listsId = []
        for lis in self.lists:
            listsId.append(lis['id'])

        board['actions'] = self.filterActions(
            board['actions'],
            ['updateCard', 'createCard'],
            listsId
        )
        return board



