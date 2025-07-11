extends Node

signal frame_finished(coordinate: Vector2)

var camera : CVCamera = CVCamera.new();
var processing: bool = false

func _ready():
	camera.open();
	camera.flip(false, false);
	frame_finished.connect(_on_frame_processing_finished)

func _process(delta):
	if processing or GameState.finished:
		return
	processing = true
	WorkerThreadPool.add_task(_process_worker)

func _process_worker():	
	call_deferred("_on_worker_finished", camera.get_coordinates())

func _on_worker_finished(coordinate: Vector2):
	frame_finished.emit(coordinate)

func _on_frame_processing_finished(coordinate: Vector2):
	processing = false
	if coordinate.x == -1 and coordinate.y == -1:
		return
		
	var team = Utils.Team.NONE
		
	if coordinate.x > camera.get_width() * 0.5:
		team = Utils.Team.BLUE
	else:
		team = Utils.Team.RED
		
	coordinate.x =  camera.get_width() - coordinate.x -  camera.get_width() * 0.5
	coordinate.y = camera.get_height() - coordinate.y - camera.get_height() * 0.5
	
	
	#Utils.add_spawner_to_scene(team, coordinate)
