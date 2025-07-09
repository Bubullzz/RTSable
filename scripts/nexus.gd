class_name Nexus

extends StaticBody2D

@export var entity_info: Entity = Entity.new()
@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var spawn_direction : Vector2
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	entity_info.team_changed.connect(_on_team_changed)
	entity_info.died.connect(_on_death)
	if entity_info.team == Utils.Team.BLUE:
		spawn_direction = Vector2.RIGHT
	else:
		spawn_direction = Vector2.LEFT

func _on_timer_timeout() -> void:
	var unit = preload("res://scenes/unit.tscn").instantiate()
	unit.global_position = 10 * spawn_direction + randf() * Vector2.UP + global_position
	unit.entity_info.team = entity_info.team
	unit.entity_info.role = Utils.Role.UNIT
	get_parent().add_child(unit)

func _on_team_changed() -> void:
	sprite.texture = Utils.get_sprite(entity_info)
	#opponent_nexus = Utils.get_opponent_nexus(entity_info.team)

func _on_death() -> void:
	print("Game Over")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging = !dragging
		drag_offset = global_position - get_global_mouse_position()

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
		if Input.is_key_pressed(KEY_ESCAPE):
			dragging = false
