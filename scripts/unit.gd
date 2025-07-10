class_name Unit

extends CharacterBody2D

@export var entity_info: Entity = Entity.new()
@onready var sprite: Sprite2D = $Sprite
@onready var navigation_agent = $NavigationAgent2D
@onready var opponent_nexus : Nexus = Utils.get_opponent_nexus(entity_info.team)
@onready var attack_timer: Timer = $AttackTimer
var target: Node2D = null # Nexus or unit to attack
var focus: bool = true

var udp_manager: UDPManager
var screen_size: Vector2
var screen_offset: Vector2
var max_index: int
var money_value = 6

func _ready() -> void:
	entity_info = entity_info.duplicate(true)
	
	udp_manager = get_tree().root.get_node("MainScene/Processing/UDP")
	screen_size = get_tree().root.get_node("MainScene/Camera").get_viewport().get_visible_rect().size
	screen_offset = Vector2(-screen_size.x * 0.5, -screen_size.y * 0.5)
	max_index = udp_manager.RECEIVE_WIDTH * udp_manager.RECEIVE_HEIGHT
	navigation_agent.max_speed = entity_info.speed
	
	entity_info.team_changed.connect(_on_team_changed)
	entity_info.died.connect(_on_death)
	

func _physics_process(_delta: float) -> void:
	if target == null and not navigation_agent.is_navigation_finished():
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()
		
		var position_screen = global_position - screen_offset
		var normalized_x = clamp(position_screen.x / screen_size.x, 0.0, 1.0)
		var normalized_y = clamp(position_screen.y / screen_size.y, 0.0, 1.0)
		var x = int(floor(normalized_x * udp_manager.RECEIVE_WIDTH))
		var y = int(floor(normalized_y * udp_manager.RECEIVE_HEIGHT))
		
		var index = clamp(max_index - y * udp_manager.RECEIVE_WIDTH - x, 0, max_index)
		var value = udp_manager.MAX_VALUE - udp_manager.received_data[index]
		var desired_speed = entity_info.speed
		if value < GameState.low_threshold - GameState.low_threshold * 0.5:
			desired_speed *= 1.0 - clamp((GameState.low_threshold - value) / GameState.low_threshold, 0.0, 0.9)

		elif value > GameState.low_threshold + GameState.low_threshold * 2:
			desired_speed *= 1.0 - clamp((value - GameState.high_threshold) / (255 - GameState.high_threshold), 0.0, 0.9)
				
		var desired_velocity = direction * desired_speed
		navigation_agent.set_velocity(desired_velocity)
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		queue_free()

func _on_timer_timeout() -> void:
	navigation_agent.set_target_position(opponent_nexus.global_position)

func _on_team_changed() -> void:
	sprite.texture = Utils.get_sprite(entity_info)
	if entity_info.team == Utils.Team.RED:
		navigation_agent.avoidance_mask = 1
		navigation_agent.avoidance_layers = 1
	elif entity_info.team == Utils.Team.BLUE:
		navigation_agent.avoidance_mask = 2
		navigation_agent.avoidance_layers = 2

# Maybe call defered
func _on_death() -> void: 
	opponent_nexus.add_money(money_value)
	queue_free()

func forget_target() -> void:
	if target != null:
		target.entity_info.died.disconnect(_on_target_death)
		target = null
	
func _on_detection_zone_body_entered(body:Node2D) -> void:
	if target == null and focus and (body is Unit or body is Nexus) and body.entity_info.team != entity_info.team:
		attack_timer.start(1)
		target = body
		target.entity_info.died.connect(_on_target_death)

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if target == body:
		forget_target()

func _on_target_death() -> void:
	forget_target()

func _on_attack_timer_timeout() -> void:
	if target == null:
		return
	var projectile = preload("res://scenes/projectile.tscn").instantiate()
	projectile.damage = entity_info.damage
	projectile.position = global_position
	projectile.proj_direction = (target.global_position - global_position).normalized()
	projectile.team = entity_info.team
	attack_timer.start(1)
	get_parent().add_child(projectile)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if target == null:
		velocity = safe_velocity
		move_and_slide()
		
		
