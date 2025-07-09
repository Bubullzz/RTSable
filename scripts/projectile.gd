class_name Projectile
extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite

var damage: int
var proj_direction: Vector2
@export var speed : int = 100

var team: Utils.Team = Utils.Team.NONE

func _ready() -> void:
    sprite.texture = Utils._get_projectile_sprite(team)

func _physics_process(delta: float) -> void:
    position += delta * proj_direction * speed
