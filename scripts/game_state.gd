extends Node

var blue_nexus: Nexus
var red_nexus: Nexus
var finished: bool = false
		
@export var low_threshold: int = 10
@export var high_threshold: int = 220
var gradient: Gradient

func _ready() -> void:
	gradient = preload("res://scenes/grad.tres")
	call_deferred("setup_nexus_references")

func setup_nexus_references() -> void:
	blue_nexus = get_tree().get_first_node_in_group("blue_nexus")
	red_nexus = get_tree().get_first_node_in_group("red_nexus")
