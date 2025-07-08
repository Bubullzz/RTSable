extends Sprite2D

@export var LOW: int
@export var HIGH: int
@export var g : Gradient
var current_array := []

var udp := PacketPeerUDP.new()
const PORT = 5555
const WIDTH = 640
const HEIGHT = 480
var received_data := PackedByteArray()
var expecting_new_frame := false
var invalidate_path : bool = true
var GRID_WIDTH = 160
var GRID_HEIGHT = 120

@onready var astar : AStar2D = AStar2D.new()

func _ready():
	if udp.bind(PORT, "*", 1024 * 1024) != OK:
		push_error("Failed to start UDP client")
	else:
		print("Godot UDP client listening...")
	
	current_array.resize(WIDTH * HEIGHT)

	var unit = preload("res://objects/unit.tscn").instantiate().create(Teams.Team.BLUE, Vector2(10,10))
	add_child(unit)
	position = Vector2(get_viewport().get_visible_rect().size / 2)
	
	
func threshold_astar(pixel: int):
	return pixel < LOW or pixel > HIGH
	
	
func compute_graph():
	if not invalidate_path:
		return
	invalidate_path = false
	
	var id : int = 0
	var graph : Dictionary = {}
	
	var image : Image = texture.get_image()
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var pixel_current = get_heightmap_pixel(x, y)
			
			if (threshold_astar(pixel_current)):
				
				
				id += 1
			
func get_heightmap_pixel(x: int, y: int) -> float:
	var map_size = texture.get_size()
	var rect = get_rect()
	
	# Convert scaled world position to map coordinates
	var map_x = int((x / rect.size.x) * map_size.x)
	var map_y = int((y / rect.size.y) * map_size.y)
	
	# Clamp to map bounds
	map_x = clamp(map_x, 0, map_size.x - 1)
	map_y = clamp(map_y, 0, map_size.y - 1)

	# Sample depth (assuming grayscale where darker = deeper)
	var color = 1.0 - current_array[map_y * map_size.x + map_x] / 255.0
	return 1.0 - color

func _process(_delta):
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet().duplicate()
		
		var packet_string = packet.get_string_from_ascii()
		
		if packet_string == "NEW_FRAME":
			#print("Received NEW_FRAME signal")
			# Reset buffer for new frame
			received_data = PackedByteArray()
			expecting_new_frame = true
		elif packet_string == "END_FRAME":
			#print("Received END_FRAME signal")
			# Process the complete frame
			if received_data.size() == WIDTH * HEIGHT:
				update_texture(received_data)
			else:
				print("Frame size mismatch: expected", WIDTH * HEIGHT , "got", received_data.size())
			received_data = PackedByteArray()
			expecting_new_frame = false
		else:
			# Add data to buffer
			received_data += packet

func update_texture(data: PackedByteArray):
	var processed_img = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGB8)
	for i in range(data.size()):

		# Store original value in current_array
		current_array[i] = data[i]
		# Process the value through your custom function
		var processed_value = g.sample(data[i] / 255.0) 
		
		# Calculate pixel position
		var x = i % WIDTH
		var y = i / WIDTH
		
		# Set the processed pixel value (convert to 0-1 range for Color)
		processed_img.set_pixel(x, y, processed_value)
	if texture == null:
		texture = ImageTexture.create_from_image(processed_img)
		var camera = get_parent().get_node("Camera2D")
		var viewport_size = camera.get_viewport().get_visible_rect().size
		var texture_size = texture.get_size()
		
		scale = viewport_size / texture_size

		# Center the sprite to the camera
		global_position = camera.global_position
		
		
	else:
		texture.update(processed_img)
	compute_graph()
	
	#print("Updated texture with value: ", data[8])


func _on_timer_timeout() -> void:
	invalidate_path = true
