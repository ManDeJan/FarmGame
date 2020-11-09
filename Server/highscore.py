import sqlite3
import base64
from itertools import cycle
from flask import Flask, request
from datetime import datetime
app = Flask(__name__)
conn = sqlite3.connect('highscores.sqlite')


@app.route('/')
def home():
    return '''
    <html>
    <head>
    </head>
    <body>
        <a href="/highscores">Highscores</a>
    </body>
    </html>
    '''


def show_highscores():
    return_val = '''<html>
    <head>
    </head>
    <body>
    <table>
    <thead>
    <table>
    <tr>
        <th>Name</th>
        <th>Highscore</th>
    </tr>
    '''
    cursor = conn.execute(
        '''SELECT Username, Score FROM highscores ORDER BY highscores.Score LIMIT 50''')
    print(cursor)
    for row in cursor:
        print(row)
        return_val += f'''
        <tr>
            <td>{row[0]}</td>
            <td>{row[1]}</td>
        </tr>
        '''
    return_val += '''
    </table>
    </body>
    </html>
    '''
    return return_val


def decrypt_highscore(encrypted_text):
    return (''.join([chr(x ^ ord(y)) for (x, y) in zip(base64.decodestring(encrypted_text.encode('ascii')), cycle('THIS IS BEST ENCRYPTION METHOD'))])).split(':')


def post_highscore():
    name, highscore,validation = decrypt_highscore(request.form['super_secret'])
    print(name, highscore, validation)
    if validation != 'THISMUSTALWAYSBETHESAME':
        return ("NO", 404)
    conn.execute('''INSERT INTO highscores(Timestamp, Username, Score) VALUES (?,?,?)''', [
                 int(datetime.now().timestamp()), name, highscore])
    conn.commit()
    return "OK"


@app.route('/highscores', methods=['GET', 'POST'])
def highscores():
    print("EYY")
    if request.method == 'GET':
        return show_highscores()
    else:
        return post_highscore()
