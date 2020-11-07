extends Node2D

# Collision layer defs:
# 1 = player
# 2 = wall
# 3 = throwable
# 4 = plant
# 5 = seedifyable

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
    rng.randomize()
    $UI.update_corn(corn_count)
    $UI.update_zaad(seed_count)
    $UI.update_month(months[current_month])

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(_delta):
    pass
    

func _input(ev):
    if ev.is_action_pressed('maximize'):
        OS.window_fullscreen = !OS.window_fullscreen


var seed_count = 10
var corn_count = 0
const velocity_scale = 1.5
var corn = preload('res://throwables/Corn.tscn')
var corn_seed = preload('res://throwables/Seed.tscn')

func _on_Player_throw(node):
    var throwed_node = node
    if not node:
        if seed_count <= 0:
            return
        throwed_node = corn_seed.instance()
        add_child(throwed_node)
        
        throwed_node.sprite.flip_v = bool(rng.randi_range(0, 1))
        throwed_node.sprite.flip_h = bool(rng.randi_range(0, 1))
        throwed_node.position = $Player.position
        throwed_node.position.y -= 8
        
        seed_count = ~-seed_count
        $UI.update_zaad(seed_count)

    throwed_node.set_physics_process(true)
    var state = $Player.state
    var AnimState = $Player.AnimState

    var player_velocity = $Player.velocity

    throwed_node.velocity = player_velocity * velocity_scale
    
    throwed_node.position.x = clamp(throwed_node.position.x,  0, 320)
    throwed_node.position.y = clamp(throwed_node.position.y, 20, 180)
    
    if state == AnimState.DOWN:
        throwed_node.velocity.y += 2
        $Player.velocity.y -= 2
    if state == AnimState.UP:
        throwed_node.velocity.y -= 2
        $Player.velocity.y += 2
    if state == AnimState.RIGHT:
        throwed_node.velocity.x += 2
        $Player.velocity.x -= 2
    if state == AnimState.LEFT:
        throwed_node.velocity.x -= 2
        $Player.velocity.x += 2
    
    
    
var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
var current_month = 0
func _on_MonthTimer_timeout():
    current_month += 1
    if current_month == 12:
        current_month = 0 # temp fix
    $UI.update_month(months[current_month])


func _on_Seedificator_consume(node):
    seed_count += rng.randi_range(2, 3)
    $UI.update_zaad(seed_count)
    node.queue_free()
    print(node)
    print('succc the corn')


func _on_Player_pickup():
    print('pick up the pace boii')
#    var pickupables = get_tree().get_nodes_in_group("Throwables")
    if $Player.holding: return
    var pickupables = $Player/PickupRange.get_overlapping_bodies()
    
    if not pickupables: return
    var nearest_thing = null
    for thing in pickupables:
        if thing.is_in_group('Throwables'):
            nearest_thing = thing
    for thing in pickupables:
        if thing.is_in_group('Throwables') and thing.global_position.distance_to($Player.global_position) < nearest_thing.global_position.distance_to($Player.global_position):
            nearest_thing = thing
    if not nearest_thing: return
    var distance = nearest_thing.global_position.distance_to($Player.global_position)

    nearest_thing.set_physics_process(false)
    $Player.hold(nearest_thing)
