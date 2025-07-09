class_name Projectile
extends Area2D

@onready var sprite: Sprite2D = $Sprite
@onready var notifier: VisibleOnScreenNotifier2D = $Notifier

var damage: int
var proj_direction: Vector2
@export var speed : int = 100

var team: Utils.Team = Utils.Team.NONE:
	set(value):
		_texture = Utils._get_projectile_sprite(value)
		team = value
		
var _texture: Texture2D = null

func _ready() -> void:
	if _texture != null:
		sprite.texture = _texture

func _process(delta: float) -> void:
	position += delta * proj_direction * speed
	if not notifier.is_on_screen():
		queue_free()
