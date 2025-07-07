extends CharacterBody2D

@export var health : int
@export var damage : int

var team : Teams.Team = Teams.Team.NONE
var direction

func _ready() -> void:
    if team == Teams.Team.BLUE:
        direction = Vector2.RIGHT
    else:
        direction = Vector2.LEFT
func _physics_process(delta: float) -> void:
    velocity = direction * 100.0
    move_and_slide()

    
func create(t: Teams.Team, pos: Vector2) -> Node2D:
    team = t
    if team == Teams.Team.BLUE:
        %Sprite.texture = preload("res://sprites/blob_blue.png")
    self.global_position = pos
    return self

    
