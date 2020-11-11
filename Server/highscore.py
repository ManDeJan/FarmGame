#!/bin/python
import sqlite3
import base64
from itertools import cycle
from flask import Flask, request, g, escape
from datetime import datetime
app = Flask(__name__)

DATABASE = 'highscores.sqlite'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()


def show_highscores():
    conn = get_db()
    return_val = '''<html>
    <head>
    
    <style>
        html {
            font-family: 'Open Sans', sans-serif;
            margin: 0;
        }

        body {
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            margin: 0;
            background: #232323;
            color: #fdfff1;
            font-size: 4vw;
            font-weight: 500;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
        }
    </style>
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
        '''SELECT Username, Score FROM highscores ORDER BY highscores.Score DESC LIMIT 50''')
    # print(cursor)
    for row in cursor:
        # print(row)
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
    print('werkpls')
    conn = get_db()
    name, highscore,validation = decrypt_highscore(request.form['super_secret'])
    # print(name, highscore, validation)
    if validation != 'THISMUSTALWAYSBETHESAME':
        return ("NO", 404)
    name = escape(name)
    highscore = escape(highscore)
    if len(name) > 20:
        name = name[:20]
    if not name:
        name = 'Anonymous'
    conn.execute('''INSERT INTO highscores(Timestamp, Username, Score) VALUES (?,?,?)''', [
                 int(datetime.now().timestamp()), name, highscore])
    conn.commit()
    conn.close()
    return "OK"


@app.route('/highscores', methods=['GET', 'POST'])
def highscores():
    print('biepboop all is cool')
    if request.method == 'GET':
        return show_highscores()
    else:
        return post_highscore()
        
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False)
