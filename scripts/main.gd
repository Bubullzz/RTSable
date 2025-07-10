extends Node2D

@export var gradient: Gradient
var low: int
var high: int

const STEP: float = 0.05

func _ready() -> void:
	gradient = GameState.gradient
	low = GameState.low_threshold
	high = GameState.high_threshold
	$BlueNexus.add_to_group("blue_nexus")
	$RedNexus.add_to_group("red_nexus")

		
	%PinkHealthBar.max_value = $RedNexus.entity_info.health
	%PinkHealthBar.value = $RedNexus.entity_info.health

	%BlueHealthBar.max_value = $BlueNexus.entity_info.health
	%BlueHealthBar.value = $BlueNexus.entity_info.health

func _process(_delta: float) -> void:
	var shift: bool = Input.is_key_pressed(KEY_SHIFT)
	if Input.is_action_pressed("increase_top") and shift:
		increase_top_threshold()
	elif Input.is_action_pressed("decrease_top") and not shift:
		decrease_top_threshold()
	elif Input.is_action_pressed("increase_bottom") and not shift:
		increase_bottom_threshold()
	elif Input.is_action_pressed("decrease_bottom") and shift:
		decrease_bottom_threshold()
	elif Input.is_action_just_pressed("add_spawner_blue") and not shift:
		add_spawner_to_scene(Utils.Team.BLUE)
	elif Input.is_action_just_pressed("add_spawner_red") and shift:
		add_spawner_to_scene(Utils.Team.RED)
		

func add_spawner_to_scene(team : Utils.Team):
	var mouse_pos = get_global_mouse_position()
	var spawner: Nexus = Utils.NEXUS_SCENE.instantiate()
	
	spawner.entity_info.role = Utils.Role.SPAWNER
	spawner.entity_info.team = team
	spawner.position = mouse_pos
	spawner.entity_info.health = Utils.SPAWNER_HEALTH
	
	add_child(spawner)
	spawner.change_timeout(10)
	
	
func increase_bottom_threshold():

	var offsets := gradient.offsets

	var new_offset = clamp(offsets[1] + STEP, 0.0, offsets[2] - 0.01)
	gradient.set_offset(1, new_offset)
	GameState.low_threshold += 1
	
func decrease_bottom_threshold():
	var offsets := gradient.offsets

	var new_offset = clamp(offsets[1] - STEP, offsets[0] + 0.01, 1.0)
	gradient.set_offset(1, new_offset)
	GameState.low_threshold -= 1

func increase_top_threshold():
	var offsets := gradient.offsets
	var size = offsets.size()

	var new_offset = clamp(offsets[size - 2] + STEP, 0.0, offsets[size - 1] - 0.01)
	gradient.set_offset(size - 2, new_offset)

	GameState.high_threshold += 1

func decrease_top_threshold():
	var offsets := gradient.offsets
	var size = offsets.size()

	var new_offset = clamp(offsets[size - 2] - STEP, offsets[size - 3] + 0.01, 1.0)
	gradient.set_offset(size - 2, new_offset)

	GameState.high_threshold -= 1
