extends Node

enum Team {
	RED,
	BLUE,
	NONE,
}

enum Role {
	UNIT,
	NEXUS,
	SPAWNER,
	NONE,
}

enum Attack {
	RANGED,
	MELEE,
}

const SPAWNER_HEALTH = 500
const NEXUS_SCENE = preload("res://scenes/nexus.tscn")
const UNIT_SCENE = preload("res://scenes/unit.tscn")

func _get_unit_sprite(team: Team):
	match team:
		Utils.Team.RED:
			return preload("res://sprites/blob_pink.png")
		Utils.Team.BLUE:
			return preload("res://sprites/blob_blue.png")
		_:
			print("Sprite team not found!")
			return preload("res://sprites/icon.svg")

func _get_dead_king_sprite(team: Team):
	match team:
		Utils.Team.RED:
			return preload("res://sprites/red_king_dead.png")
		Utils.Team.BLUE:
			return preload("res://sprites/blue_king_dead.png")
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
			
func _get_sawner_sprite(team: Team):
	match team:
		Utils.Team.RED:
			return preload("res://sprites/pink_tent.png")
		Utils.Team.BLUE:
			return preload("res://sprites/blue_tent.png")
		_:
			return preload("res://sprites/icon.svg")

func _get_projectile_sprite(team: Team):
	match team:
		Utils.Team.RED:
			return preload("res://sprites/pink_preojectile.png")
		Utils.Team.BLUE:
			return preload("res://sprites/blue_projectile.png")
		_:
			print("Sprite nexus team not found!")
			return preload("res://sprites/icon.svg")

func get_sprite(entity: Entity):

	match entity.role:
		Utils.Role.UNIT:
			return _get_unit_sprite(entity.team)
		Utils.Role.NEXUS:
			return _get_nexus_sprite(entity.team)
		Utils.Role.SPAWNER:
			return _get_sawner_sprite(entity.team)
		_:
			print("Sprite role not found!")
			return preload("res://sprites/icon.svg")

func get_nexus(team: Team):
	match team:
		Utils.Team.RED:
			return GameState.red_nexus
		Utils.Team.BLUE:
			return GameState.blue_nexus
		_:
			print("Opponent not found!")
			return null				

func get_opponent_nexus(team: Team):
	match team:
		Utils.Team.RED:
			return GameState.blue_nexus
		Utils.Team.BLUE:
			return GameState.red_nexus
		_:
			print("Opponent not found!")
			return null



			
func team_string(team: Team) -> String:
	match team:
		Utils.Team.RED:
			return "Red"
		Utils.Team.BLUE:
			return "Blue"
		_:
			return "None"
