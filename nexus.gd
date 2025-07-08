extends StaticBody2D

@export var health : int
@export var team : Teams.Team

var spawn_direction : Vector2

func _ready() -> void:
	if team == Teams.Team.BLUE:
		spawn_direction = Vector2.RIGHT
	else:
		spawn_direction = Vector2.LEFT

func _on_timer_timeout() -> void:
	var unit = preload("res://objects/unit.tscn").instantiate().create(team, 10 * spawn_direction + randf() * Vector2.UP)
	add_child(unit)
	pass # Replace with function body.
