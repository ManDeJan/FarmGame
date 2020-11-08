extends StaticBody2D


signal spawn_corn

var stage = 0
func _ready():
    connect("spawn_corn", get_tree().get_root().get_node("World"), "_on_Plant_spawn_corn")
    set_stage()

func set_stage():
    if stage <= 2:
        $Timer.wait_time = [2,3,4][stage]
        $Timer.start()
        $Sprite.frame = stage
    else:
        emit_signal("spawn_corn", position, self)

func _on_Timer_timeout():
    stage += 1
    set_stage()
