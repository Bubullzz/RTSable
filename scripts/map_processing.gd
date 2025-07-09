class_name MapProcessing

extends Node

@export var udp_manager: UDPManager
@onready var tileset: TileMapLayer = %LogicMap
@onready var map: Sprite2D = %Map
@onready var camera: Camera2D = %Camera

const TEXTURE_SIZE := Vector2i(udp_manager.RECEIVE_WIDTH, udp_manager.RECEIVE_HEIGHT)
var processed_image: Image = Image.create(TEXTURE_SIZE[0], TEXTURE_SIZE[1], false, Image.FORMAT_RGB8)

var pixel_buffer: PackedByteArray

func _ready() -> void:
	if map.texture == null:
		map.texture = ImageTexture.create_from_image(processed_image)
		var viewport_size: Vector2i = camera.get_viewport().get_visible_rect().size
		map.scale = viewport_size / TEXTURE_SIZE
		map.global_position = camera.global_position
		
	pixel_buffer.resize(TEXTURE_SIZE[0] * TEXTURE_SIZE[1] * 3)
		
func _on_udp_frame_received(frame: PackedByteArray):
	var size: int = frame.size()
	for i in range(size):
		var d: float = udp_manager.MAX_VALUE - frame[size - i - 1]

		var processed_value: Color = GameState.gradient.sample(d / udp_manager.MAX_VALUE) 
		var index: int = i * 3

		pixel_buffer[index] = int(processed_value.r * 255)
		pixel_buffer[index + 1] = int(processed_value.g * 255)
		pixel_buffer[index + 2] = int(processed_value.b * 255)
		
	processed_image = Image.create_from_data(TEXTURE_SIZE[0], TEXTURE_SIZE[1], false, Image.FORMAT_RGB8, pixel_buffer)
	map.texture.update(processed_image)
