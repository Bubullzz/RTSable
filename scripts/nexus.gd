class_name Nexus

extends StaticBody2D

@export var entity_info: Entity = Entity.new()
@onready var sprite: Sprite2D = $Sprite
@onready var timer: Timer = %SpawnTime

var spawn_direction : Vector2
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var money: int = 0

func _ready() -> void:
	entity_info = entity_info.duplicate()
	entity_info.team_changed.connect(_on_team_changed)
	entity_info.died.connect(_on_death)
	if entity_info.team == Utils.Team.BLUE:
		spawn_direction = Vector2.RIGHT
	else:
		spawn_direction = Vector2.LEFT
		
func change_timeout(time: int) -> void:
	timer.wait_time =  time

func _on_timer_timeout() -> void:
	var unit = Utils.UNIT_SCENE.instantiate()
	unit.global_position = 10 * spawn_direction + randf() * Vector2.UP + global_position
	unit.entity_info.team = entity_info.team
	unit.entity_info.role = Utils.Role.UNIT
	get_parent().add_child(unit)

func _on_team_changed() -> void:
	sprite.texture = Utils.get_sprite(entity_info)

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


func add_money(amount: int) -> void:
	money += amount
	if entity_info.team == Utils.Team.RED:
		%PinkInfo.text = str(money)
	else:
		%BlueInfo.text = str(money)
	print(Utils.team_string(entity_info.team), "Money: ", money)
