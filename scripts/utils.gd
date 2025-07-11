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

const SPAWNER_PRICE = 100
const SPAWNER_HEALTH = 500
const NEXUS_SCENE = preload("res://scenes/nexus.tscn")
const UNIT_SCENE = preload("res://scenes/unit.tscn")

func add_spawner_to_scene(team : Utils.Team, p: Vector2):
	
	var nexus: Nexus = Utils.get_nexus(team)
	var opponent: Nexus = Utils.get_opponent_nexus(team)
	
	if p.x == -1 and p.y == -1:
		return
		
	print(p)
	
	if nexus.money < SPAWNER_PRICE:
		return
		
	#if p.distance_to(opponent.global_position) < 150:
	#	return
		
	nexus.money -= SPAWNER_PRICE

	var spawner: Nexus = Utils.NEXUS_SCENE.instantiate()
	
	spawner.entity_info.role = Utils.Role.SPAWNER
	spawner.entity_info.team = team
	spawner.position = p
	spawner.entity_info.health = Utils.SPAWNER_HEALTH
	
	add_child(spawner)
	spawner.change_timeout(10)

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
