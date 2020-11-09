extends KinematicBody2D

signal throw
signal pickup

func _ready():
    print('sprite ready bois')

const physics_fps = 60.0


const acceleration = 0.5
const friction = 0.15
const max_speed = 3.0

var velocity = Vector2.ZERO
var speed_modifier = 1.0
var holding = null

onready var animPlayer = $AnimationPlayer

enum AnimState {LEFT, RIGHT, UP, DOWN}
var state = AnimState.RIGHT

func _physics_process(delta):
    var delta_fps = delta * physics_fps
    # animation
    if not state == AnimState.RIGHT and (Input.is_action_just_pressed('ui_right')):
        state = AnimState.RIGHT
        animPlayer.play('right')
    elif not state == AnimState.LEFT and (Input.is_action_just_pressed('ui_left')): 
        state = AnimState.LEFT  
        animPlayer.play('left')
    elif not state == AnimState.DOWN and (Input.is_action_just_pressed('ui_down')): 
        state = AnimState.DOWN  
        animPlayer.play('down')
    elif not state == AnimState.UP and (Input.is_action_just_pressed('ui_up')):   
        state = AnimState.UP    
        animPlayer.play('up')
    
    # inputs
    var right = Input.get_action_strength('ui_right')
    var left  = Input.get_action_strength('ui_left')
    var down  = Input.get_action_strength('ui_down')
    var up    = Input.get_action_strength('ui_up')
    
    var input_vector = Vector2.ZERO
    input_vector.x = (right - left) * speed_modifier
    input_vector.y = (down  - up)   * speed_modifier
    
    input_vector = input_vector.normalized()
    if input_vector != Vector2.ZERO:
        velocity += input_vector * acceleration * delta_fps
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta_fps)
    
    #print(velocity)
    velocity = velocity.clamped(max_speed * speed_modifier)

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
            
    if holding and is_instance_valid(holding):
        holding.position = position
        holding.position.y -= 24
        
func _process(_delta):
    if Input.is_action_just_pressed('throw'):
        if holding and is_instance_valid(holding): 
            emit_signal('throw', holding)
            holding = null
        else:
            emit_signal("pickup")
    if Input.is_action_just_pressed('throw_zaad'): 
        emit_signal('throw', null)

func hold(node):
    if not is_instance_valid(node): return
    holding = node
