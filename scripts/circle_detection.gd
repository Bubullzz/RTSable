extends Node

signal frame_finished(coordinate: Vector2)

var camera : CVCamera = CVCamera.new();
var processing: bool = false

func _ready():
	camera.open();
	camera.flip(true, false);
	frame_finished.connect(_on_frame_processing_finished)

func _process(delta):
	if processing:
		return
	processing = true
	WorkerThreadPool.add_task(_process_worker)

func _process_worker():	
	call_deferred("_on_worker_finished", camera.get_coordinates())

func _on_worker_finished(coordinate: Vector2):
	frame_finished.emit(coordinate)

func _on_frame_processing_finished(coordinate: Vector2):
	processing = false
	print(coordinate)
