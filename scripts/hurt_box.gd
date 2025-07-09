extends Area2D
@onready var collision: CollisionShape2D = $HurtBoxShape

@export var shape: Shape2D:
	set(value):
		_shape = value
		
var _shape: Shape2D = null

func _ready() -> void:
	if _shape != null:
		collision.shape = _shape

func _on_area_entered(area: Area2D) -> void:
	if area is Projectile and area.team != get_parent().entity_info.team:
		get_parent().entity_info.on_hit(area.damage)
		area.queue_free()
