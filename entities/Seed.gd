extends KinematicBody2D

signal grow_plant

onready var sprite = $Sprite
func _ready():
    connect("grow_plant", get_tree().get_root().get_node("World"), "_on_Seed_grow_plant")
    add_to_group("Waterable")
    print('The seed must flow')

var velocity = Vector2.ZERO
const friction = 0.1
const physics_fps = 60.0
var test = "hello"

func _physics_process(delta):
    var delta_fps = delta * physics_fps

    velocity = velocity.move_toward(Vector2.ZERO, friction * delta_fps)
    var col = move_and_collide(velocity * delta_fps)
    if col:
        if col.collider.is_in_group('Wall'):
            velocity = velocity.bounce(col.normal)
            var motion = col.remainder.bounce(col.normal) 
            move_and_collide(motion)
        else:
            col.collider.set('velocity', col.collider.velocity + velocity / 2)
            col.collider.set('velocity', col.collider.velocity + col.remainder / 2)
            velocity = velocity.bounce(col.normal) / 2
            var motion = col.remainder.bounce(col.normal) / 2
            move_and_collide(motion)
            

func water():
    emit_signal('grow_plant', position, self)
