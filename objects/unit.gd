extends CharacterBody2D

@export var health : int
@export var damage : int

@onready var map = get_node("/root/MainScene/MapBackground")
var opponent_nexus : Node2D
var target : Vector2 = Vector2.ZERO

var team : Teams.Team = Teams.Team.NONE

func _ready() -> void:
	if team == Teams.Team.BLUE:
		%Sprite.texture = preload("res://sprites/blob_blue.png")
		opponent_nexus = get_node("/root/MainScene/RedNexus")
	else:
		opponent_nexus = get_node("/root/MainScene/BlueNexus")
		
func _physics_process(_delta: float) -> void:
	pass
	
func create(t: Teams.Team, pos: Vector2) -> Node2D:
	team = t
	self.global_position = pos
	return self

	
