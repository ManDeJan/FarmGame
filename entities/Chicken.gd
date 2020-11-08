extends KinematicBody2D

signal consume
signal spawn_chicken

func _ready():
    connect("consume", get_tree().get_root().get_node("World"), "_on_Chicken_consume")
    connect("spawn_chicken", get_tree().get_root().get_node("World"), "_spawn_chicken")

const physics_fps = 60.0

const acceleration = 0.6
const friction = 0.15
const max_speed = 4.0

var velocity = Vector2.ZERO
var speed_modifier = 1.0
var target_pos = Vector2.ZERO

enum State {HUNGRY, RUNNING}
var state = State.HUNGRY
var food = 0

func _physics_process(delta):
    var delta_fps = delta * physics_fps

    var angle = get_angle_to(target_pos)
    var input_vector = Vector2.ZERO
    input_vector.x = cos(angle)
    input_vector.y = sin(angle)
    
    $chicken.flip_h = input_vector.x > 0
    
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

var eating = null


func _on_SelectTarget_timeout():
    if state == State.HUNGRY:
        var targets = get_tree().get_nodes_in_group("Edible")
        if not targets:
            target_pos.x = (randi() % 400) - 40
            target_pos.y = (randi() % 200) - 20
            return
        var target = targets[randi() % targets.size()]
        eating = target
        
        target_pos = target.position
    elif state == State.RUNNING:
        var player_pos = get_tree().get_root().get_node("World").get_node("Player").position
        var angle = get_angle_to(player_pos)
        var dist = 200
        var x = dist * cos(angle);
        var y = dist * sin(angle);
        target_pos = position; 
        target_pos.x -= x;
        target_pos.y -= y;

func _on_EatingRange_body_entered(body):
    if body == eating:
        $TimeToEat.start()
        eating = body

func _on_EatingRange_body_exited(body):
    if eating == body:
        $TimeToEat.stop()
    
func _on_TimeToEat_timeout():
    emit_signal("consume", eating)
    state = State.RUNNING
    $RunRunRun.start()


func _on_RunRunRun_timeout():
    state = State.HUNGRY
    print('Spawn chick plox')
    emit_signal("spawn_chicken")
