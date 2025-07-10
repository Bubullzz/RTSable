class_name GridManager

extends Node

@export var udp_manager: UDPManager
@export var PHYSICS_GRID_RATIO: int = 6

@onready var tileset: TileMapLayer = %LogicMap
@onready var camera: Camera2D = %Camera

const ATLAS_OBSTACLE := Vector2i(0,0)
const ATLAS_PATH := Vector2i(1,0)
const ATLAS_ID: int = 0

var update_grid: bool = true

func _ready() -> void:
	tileset.scale = camera.get_viewport().get_visible_rect().size / (Vector2(udp_manager.RECEIVE_WIDTH, udp_manager.RECEIVE_HEIGHT) * 16) * PHYSICS_GRID_RATIO
	tileset.position = camera.global_position - camera.get_viewport_rect().size * 0.5
	
	udp_manager.frame_received.connect(_on_udp_frame_received)
	
func _on_udp_frame_received(frame: PackedByteArray):
	
	if not update_grid:
		return
		
	update_grid = false
	
	var size: int = frame.size()
	for i in range(size):
		var d: float = udp_manager.MAX_VALUE - frame[size - i - 1]
		var x: int = i % udp_manager.RECEIVE_WIDTH
		var y: int = i / udp_manager.RECEIVE_WIDTH
		var offset: float = PHYSICS_GRID_RATIO * 0.5
		
		if (x % PHYSICS_GRID_RATIO != offset or y % PHYSICS_GRID_RATIO != offset):
			continue
		var cell_coord := Vector2i(x / PHYSICS_GRID_RATIO, y / PHYSICS_GRID_RATIO)
			
		var atlas_coord: Vector2i
		if d > GameState.high_threshold or d < GameState.low_threshold:
			atlas_coord = ATLAS_OBSTACLE
		else:
			atlas_coord = ATLAS_PATH
				
		if tileset.get_cell_atlas_coords(cell_coord) != atlas_coord:
			tileset.set_cell(cell_coord, ATLAS_ID, atlas_coord)


func _on_timer_timeout() -> void:
	update_grid = true
