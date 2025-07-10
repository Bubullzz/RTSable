class_name GridManager

extends Node

signal frame_finished(tile_changed: Array)

@export var udp_manager: UDPManager
@export var PHYSICS_GRID_RATIO: int = 6

@onready var tileset: TileMapLayer = %LogicMap
@onready var camera: Camera2D = %Camera

const ATLAS_OBSTACLE := Vector2i(0,0)
const ATLAS_PATH := Vector2i(1,0)
const ATLAS_ID: int = 0

var new_frame: PackedByteArray
var processing: bool = false

func _ready() -> void:
	tileset.scale = camera.get_viewport().get_visible_rect().size / (Vector2(udp_manager.RECEIVE_WIDTH, udp_manager.RECEIVE_HEIGHT) * 16) * PHYSICS_GRID_RATIO
	tileset.position = camera.global_position - camera.get_viewport_rect().size * 0.5
	
	udp_manager.frame_received.connect(_on_udp_frame_received)
	frame_finished.connect(_on_frame_processing_finished)
	
func _on_udp_frame_received(frame: PackedByteArray):
	
	# While processing, if we receive new frame to process, store it (and process last)
	if processing:
		new_frame = frame.duplicate()
		return
		
	processing = true
	var worker_data = {
		"frame": frame,
		"max_value": udp_manager.MAX_VALUE,
		"receive_width": udp_manager.RECEIVE_WIDTH,
		"physics_grid_ratio": PHYSICS_GRID_RATIO,
		"high_threshold": GameState.high_threshold,
		"low_threshold": GameState.low_threshold,
		"atlas_obstacle": ATLAS_OBSTACLE,
		"atlas_path": ATLAS_PATH
	}
	WorkerThreadPool.add_task(_process_worker.bind(worker_data))

func _process_worker(data: Dictionary):
	var frame = data.frame
	var max_value = data.max_value
	var receive_width = data.receive_width
	var physics_grid_ratio = data.physics_grid_ratio
	var high_threshold = data.high_threshold
	var low_threshold = data.low_threshold
	var atlas_obstacle = data.atlas_obstacle
	var atlas_path = data.atlas_path
	
	var tile_changes = []
	var size: int = frame.size()
	var offset: float = physics_grid_ratio * 0.5
	
	for i in range(size):
		var d: float = max_value - frame[size - i - 1]
		var x: int = i % receive_width
		var y: int = i / receive_width
		
		if (x % physics_grid_ratio != offset or y % physics_grid_ratio != offset):
			continue
			
		var cell_coord := Vector2i(x / physics_grid_ratio, y / physics_grid_ratio)
		var atlas_coord: Vector2i
		
		if d > high_threshold or d < low_threshold:
			atlas_coord = atlas_obstacle
		else:
			atlas_coord = atlas_path
		
		# Store the change instead of applying it
		tile_changes.append({
			"coord": cell_coord,
			"atlas": atlas_coord
		})
	
	# Send results back to main thread
	call_deferred("_on_worker_finished", tile_changes)

func _on_worker_finished(tile_changed: Array):
	frame_finished.emit(tile_changed)

func _on_frame_processing_finished(tile_changed: Array):
	
	for change in tile_changed:
		if tileset.get_cell_atlas_coords(change.coord) != change.atlas:
			tileset.set_cell(change.coord, ATLAS_ID, change.atlas)
	
	processing = false
			
	if new_frame != null:
		var tmp = new_frame.duplicate()
		new_frame = PackedByteArray()
		_on_udp_frame_received(tmp)
