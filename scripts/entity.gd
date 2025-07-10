class_name Entity

extends Resource

signal team_changed
signal died

@export_category("Entity information")
@export_range(1, 1000, 1) var health: int = 100
@export_range(0, 100, 1) var damage : int  = 5
@export var team : Utils.Team = Utils.Team.NONE:
	set(value):
		team = value
		call_deferred("emit_signal", "team_changed")
@export var role : Utils.Role = Utils.Role.NONE
@export var attack: Utils.Attack = Utils.Attack.MELEE
@export_range(0, 1000, 1) var speed: int = 50

func on_hit(_damage: int) -> void:
	health -= _damage
	if health <= 0:
		emit_signal("died")
