extends Node

var camera : CVCamera = CVCamera.new();
var coordinates : Vector2;
var update: bool = true

func _ready():
	camera.open();
	camera.flip(true, false);

func _process(delta):
	if not update:
		return
	update = false
	coordinates = camera.get_coordinates();
	print(coordinates);


func _on_cv_timer_timeout() -> void:
	update = true
