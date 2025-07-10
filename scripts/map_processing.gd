class_name MapProcessing

extends Node

signal frame_finished(result_buffer: PackedByteArray)

@export var udp_manager: UDPManager
@onready var tileset: TileMapLayer = %LogicMap
@onready var map: Sprite2D = %Map
@onready var camera: Camera2D = %Camera

const TEXTURE_SIZE := Vector2i(udp_manager.RECEIVE_WIDTH, udp_manager.RECEIVE_HEIGHT)
var processed_image: Image = Image.create(TEXTURE_SIZE[0], TEXTURE_SIZE[1], false, Image.FORMAT_RGB8)

var pixel_buffer: PackedByteArray

var new_frame: PackedByteArray
var processing: bool = false

func _ready() -> void:
	if map.texture == null:
		map.texture = ImageTexture.create_from_image(processed_image)
		var viewport_size: Vector2i = camera.get_viewport().get_visible_rect().size
		map.scale = viewport_size / TEXTURE_SIZE
		map.global_position = camera.global_position
		
	pixel_buffer.resize(TEXTURE_SIZE[0] * TEXTURE_SIZE[1] * 3)
	
	udp_manager.frame_received.connect(_on_udp_frame_received)
	frame_finished.connect(_on_frame_processing_finished)

		
func _on_udp_frame_received(frame: PackedByteArray):
	if processing:
		new_frame = frame.duplicate()
		return

	processing = true

	var worker_data = {
		"frame": frame,
		"max_value": udp_manager.MAX_VALUE,
		"receive_width": TEXTURE_SIZE.x,
		"receive_height": TEXTURE_SIZE.y
	}
	WorkerThreadPool.add_task(_process_worker.bind(worker_data))

func _process_worker(data: Dictionary):
	var frame: PackedByteArray = data.frame
	var max_value: float = data.max_value
	var width: int = data.receive_width
	var height: int = data.receive_height
	var size: int = frame.size()

	var result_buffer: PackedByteArray
	result_buffer.resize(width * height * 3)

	for i in range(size):
		var d: float = max_value - frame[size - i - 1]
		var color: Color = GameState.gradient.sample(d / max_value)
		var index: int = i * 3

		result_buffer[index] = int(color.r * 255)
		result_buffer[index + 1] = int(color.g * 255)
		result_buffer[index + 2] = int(color.b * 255)

	call_deferred("_on_worker_finished", result_buffer)
	
func _on_worker_finished(result_buffer: PackedByteArray):
	frame_finished.emit(result_buffer)

func _on_frame_processing_finished(result_buffer: PackedByteArray):
	pixel_buffer = result_buffer.duplicate()
	processed_image = Image.create_from_data(TEXTURE_SIZE.x, TEXTURE_SIZE.y, false, Image.FORMAT_RGB8, pixel_buffer)
	map.texture.update(processed_image)

	processing = false

	if new_frame.size() > 0:
		var tmp = new_frame.duplicate()
		new_frame = PackedByteArray()
		_on_udp_frame_received(tmp)
