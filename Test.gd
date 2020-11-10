extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
onready var kip = preload("res://entities/Chicken.tscn")
func _ready():
    var new_kip = kip.instance()
    add_child(new_kip)
    new_kip.queue_free()
    null.queue_free()
    print(new_kip)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
