extends Node

enum Team {
	RED,
	BLUE,
	NONE,
}

enum Role {
	UNIT,
	NEXUS,
	NONE,
}

enum Attack {
	RANGED,
	MELEE,
}

func _get_unit_sprite(team: Team):
	match team:
		Utils.Team.RED:
			return preload("res://sprites/blob_pink.png")
		Utils.Team.BLUE:
			return preload("res://sprites/blob_blue.png")
		_:
			print("Sprite team not found!")
			return preload("res://sprites/icon.svg")
			
func _get_nexus_sprite(team: Team):
	match team:
		Utils.Team.RED:
			return preload("res://sprites/red_king.png")
		Utils.Team.BLUE:
			return preload("res://sprites/blue_king.png")
		_:
			print("Sprite nexus team not found!")
			return preload("res://sprites/icon.svg")

func get_sprite(entity: Entity):

	match entity.role:
		Utils.Role.UNIT:
			return _get_unit_sprite(entity.team)
		Utils.Role.NEXUS:
			return _get_nexus_sprite(entity.team)
		_:
			print("Sprite role not found!")
			return preload("res://sprites/icon.svg")
			
			
func get_opponent_nexus(team: Team):
	match team:
		Utils.Team.RED:
			return GameState.blue_nexus
		Utils.Team.BLUE:
			return GameState.red_nexus
		_:
			print("Opponent not found!")
			return null
