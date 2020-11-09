extends Node2D

var SUPER_SECRET_ENCRYPTION_STRING = 'THIS IS BEST ENCRYPTION METHOD'

func encrypt_highscore(username, highscore):
    var to_encrypt = username + ':' + str(highscore) + ':THISMUSTALWAYSBETHESAME'
    var outp = PoolByteArray()
    for i in range(len(to_encrypt)):
        outp.append(ord(to_encrypt[i]) ^ ord(SUPER_SECRET_ENCRYPTION_STRING[i%len(SUPER_SECRET_ENCRYPTION_STRING)]))
    return Marshalls.raw_to_base64(outp)

func post_highscore(name, highscore):
    var query_string = 'super_secret='+encrypt_highscore(name, highscore)
    var headers = ["Content-Type: application/x-www-form-urlencoded"]
    var error
    if OS.is_debug_build():
        error = $HTTPRequest.request("https://farmgame.mandejan.nl/highscores", headers, true, HTTPClient.METHOD_POST, query_string)
    else:
        error = $HTTPRequest.request("https://farmgame.mandejan.nl/highscores", headers, true, HTTPClient.METHOD_POST, query_string) #bool is voor https
    if error != OK:
        push_error("An error occurred in the HTTP request.")

func set_score(highscore):
    $CenterContainer/VBoxContainer/GridContainer/Highscore.text = str(highscore)

func _on_Button_pressed():
    $CenterContainer/VBoxContainer/Button.disabled = true;
    post_highscore($CenterContainer/VBoxContainer/GridContainer/Name.text, $CenterContainer/VBoxContainer/GridContainer/Highscore.text)
