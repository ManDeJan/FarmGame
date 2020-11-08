extends Node2D

# Collision layer defs:
# 1 = player
# 2 = wall
# 3 = throwable
# 4 = plant
# 5 = seedifyable
# 6 = edible

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
var chicken = preload('res://entities/Chicken.tscn')
func _ready():
    rng.randomize()
    $UI.update_corn(corn_count)
    $UI.update_zaad(seed_count)
    $UI.update_month(months[current_month])
    $UI.update_cashmoney(money_count)
    $UI.update_stonk(money_value)
    play_month()


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(_delta):
    pass
    

func _input(ev):
    if ev.is_action_pressed('maximize'):
        OS.window_fullscreen = !OS.window_fullscreen


var seed_count = 10
var corn_count = 0
const velocity_scale = 1.5
var corn_seed = preload('res://entities/Seed.tscn')

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
    play_month()
    
const month_data = [
    [1, 3, 3], # 0
    [3, 4, 5], # 1
    [3, 4, 5], # 2
    [4, 5, 6], # 3
    [6, 7, 8], # 4
    [6, 7, 7], # 5
    [10, 10, 10], # 6
    [6, 6, 6], # 7
    [6, 7, 8], # 8
    [9, 10, 10], # 9
    [11, 12, 13], # 10
    [20, 0, 0], # 11       
]


func _spawn_chicken():
    var kip = chicken.instance()
    add_child(kip)
    $ChickenSpawn/ChickenSpawnSampler.offset = randi()
    kip.position = $ChickenSpawn/ChickenSpawnSampler.position
    print("B")

var wave_count = 0
func play_month():
    print("Month: {0}, Wave: {1}".format({1: wave_count, 0: current_month}))
    
    for _i in range(month_data[current_month][wave_count]):
        _spawn_chicken()
    
    wave_count += 1
    if wave_count == 3:
        wave_count = 0
        return
    yield(get_tree().create_timer($MonthTimer.wait_time / 4), "timeout");
    play_month()


func _on_Seedificator_consume(node):
    corn_count += 1 # temp
    seed_count += rng.randi_range(2, 3)
    $UI.update_zaad(seed_count)
    print(node)
    print('succc the corn')
    
    drop_if_holding(node)
    node.queue_free()

var plant_scene = preload('res://entities/Plant.tscn')
func _on_Seed_grow_plant(position, node):
    print('groei groei groei!')
    var new_plant = plant_scene.instance()
    add_child(new_plant)
    new_plant.position = position
    
    drop_if_holding(node)
    node.queue_free()
    
var corn_scene = preload('res://entities/Corn.tscn')
func _on_Plant_spawn_corn(position, node):
    print('plopperdeplopperdeplop')
    var new_corn = corn_scene.instance()
    add_child(new_corn)
    new_corn.position = position
    drop_if_holding(node)
    node.queue_free()

func _on_Chicken_consume(node):
    drop_if_holding(node)
    node.queue_free()

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
    # var distance = nearest_thing.global_position.distance_to($Player.global_position)

    nearest_thing.set_physics_process(false)
    $Player.hold(nearest_thing)

func drop_if_holding(node):
    if $Player.holding == node:
        $Player.holding = null


func _on_Mower_kill(kip):
    kip.queue_free()

var money_count = 0
var money_scene = preload('res://entities/Money.tscn')

func _on_MoneyPrinter_consume(node):
    corn_count += 1
    $UI.update_corn(corn_count)
    drop_if_holding(node)
    node.queue_free()
    for _i in range(money_value):
        var money = money_scene.instance()
        add_child(money)
        money.position = $MoneyPrinter.position
        money.position.y -= 8
        money.position.x += rand_range(-2, 2)
        money.position.y += rand_range(-2, 2)
        money.velocity.x = rand_range(-1, 1)
        money.velocity.y = rand_range(-1, 1)
        money.velocity = money.velocity.normalized()
        money.velocity *= 2

var money_value = 3 # MANEEE
func _on_StonkUpdateTimer_timeout():
    print('beep boop computer goes brrr')
    money_value += rng.randi_range(-2, 2)
    money_value = clamp(money_value, 1, 8)
    $UI.update_stonk(money_value)
    
func _on_Money_caching():
    money_count += 1
    $UI.update_cashmoney(money_count)
