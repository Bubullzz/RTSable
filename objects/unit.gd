extends Node2D

@export var health : int
@export var damage : int

var team : Teams.Team = Teams.Team.NONE

func create(t: Teams.Team, pos: Vector2) -> Node2D:
    team = t
    if team == Teams.Team.BLUE:
        %Sprite.texture = preload("res://sprites/blob_blue.png")
    self.global_position = pos
    return self

    
