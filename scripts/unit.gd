class_name Unit

extends CharacterBody2D

@export var entity_info: Entity = Entity.new()
@onready var nav_agent:  NavigationAgent2D = $NavigationAgent2D
@onready var sprite: Sprite2D = $Sprite
@onready var opponent_nexus : Nexus = Utils.get_opponent_nexus(entity_info.team)
		
func _ready() -> void:
	entity_info = entity_info.duplicate(true)
	entity_info.team_changed.connect(_on_team_changed)
	entity_info.died.connect(_on_death)
		
func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * entity_info.speed
	move_and_slide()
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		queue_free()

func _on_timer_timeout() -> void:
	if opponent_nexus.entity_info.health > 0:
		nav_agent.set_target_position(opponent_nexus.global_position)

func _on_team_changed() -> void:
	sprite.texture = Utils.get_sprite(entity_info)
	#opponent_nexus = Utils.get_opponent_nexus(entity_info.team)

func _on_death() -> void:
	queue_free()
