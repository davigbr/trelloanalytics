import flask
import trello
import analytics
import json

from flask import Flask, Response
from flask import render_template

app = Flask(__name__, static_url_path='')

@app.route("/")
def index():
    return render_template('index.html')

@app.route('/authorized/<token>')
def authorized(token):
    key = 'cb7acdb2fee72c75964b52f7888feee0'
    client = trello.Trello(key, token)
    boardId = '9O7SmOjz'
    board = client.fetchBoardAndActions(boardId)
    cards = client.fetchCardsAndActions(boardId)
    lists = client.fetchLists(boardId)
    data = analytics.Analytics(board, cards, lists);

    output = json.dumps(data.process())
    return Response(response=output.encode(),status=200, mimetype="application/json")
    #return render_template('dashboard.html', output=output)

if __name__ == "__main__":
    app.run(debug=True)



