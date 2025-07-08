extends Sprite2D

@export var LOW: int = 40
@export var HIGH: int = 200
@export var g : Gradient
var current_array := []

var udp := PacketPeerUDP.new()
const PORT = 5555
const WIDTH = 640
const HEIGHT = 480
var received_data := PackedByteArray()
var expecting_new_frame := false
var invalidate_path : bool = true
#var GRID_WIDTH = 640
#var GRID_HEIGHT = 480

var PHYSICS_GRID_RATIO := 6

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

	# Scale TileMap up 
	var camera: Camera2D = get_parent().get_node("Camera2D")
	%PhysicsTileMap.scale = camera.get_viewport().get_visible_rect().size / (Vector2(WIDTH, HEIGHT) * 16) * PHYSICS_GRID_RATIO
	%PhysicsTileMap.position = camera.global_position - camera.get_viewport_rect().size / 2

	
func threshold_astar(pixel: int):
	return pixel < LOW or pixel > HIGH
	
	
func compute_graph():
	if not invalidate_path:
		return
	invalidate_path = false
	astar = AStar2D.new()
	
	var id : int = 0
	var graph : Dictionary = {}
	#var text_size = texture.get_size() # Texture
	var rect_size = get_rect().size # World
	#var grid_size = Rect2(0, 0, WIDTH, HEIGHT).size
	#var scaleText_x = text_size.x / GRID_WIDTH
	#var scaleText_y = text_size.y / GRID_HEIGHT
	var scaleWorld_x = rect_size.x / WIDTH
	var scaleWorld_y = rect_size.y / HEIGHT
	
	#var image : Image = texture.get_image()
	
	# TODO: Use grid rect here
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var text_pos : Vector2 = Vector2(x, y)
			var world_pos : Vector2 = Vector2(x * scaleWorld_x, y * scaleWorld_y)
			var pixel_current = get_heightmap_pixel(x, y)
			# TODO: Use grid pos here
			graph[text_pos] = {"id": id, "reachable": false}
			if (threshold_astar(pixel_current)):
				astar.add_point(id, world_pos)
				graph[text_pos]["reachable"] = true
			id += 1
				
	for y in range(rect_size.y):
		for x in range(rect_size.x):
			var current_pos : Vector2 = Vector2(x, y)
			if not graph.has(current_pos):
				continue
			var current_id = graph[current_pos]["id"]
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0:
						continue
					var neigh_pos : Vector2 = Vector2(x + dx, y + dy)
					
					if graph.has(neigh_pos) and graph[neigh_pos]["reachable"]:
						var neigh_id = graph[neigh_pos]["id"]
						#var world_pos : Vector2 = astar.get_point_position(neigh_id)
						# TODO: Compute Weight here
						astar.connect_points(current_id, neigh_id, false)
	
					
	
			
func get_heightmap_pixel(x: int, y: int) -> float:
	var map_size = texture.get_size()
	#var rect = get_rect()
	
	# Convert scaled world position to map coordinates
	#var map_x = int((x / rect.size.x) * map_size.x)
	#var map_y = int((y / rect.size.y) * map_size.y)
	
	# Clamp to map bounds
	#map_x = clamp(map_x, 0, map_size.x - 1)
	#map_y = clamp(map_y, 0, map_size.y - 1)

	# Sample depth (assuming grayscale where darker = deeper)
	var color = 1.0 - current_array[y * map_size.x + x] / 255.0
	return color

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
		var d = 255 - data[i]
		current_array[i] = d
		var x = i % WIDTH
		var y = i / WIDTH
		var offset = PHYSICS_GRID_RATIO / 2
		if (x % PHYSICS_GRID_RATIO == offset && y % PHYSICS_GRID_RATIO == offset):
			var w = WIDTH / PHYSICS_GRID_RATIO
			if d > HIGH or d < LOW:
				%PhysicsTileMap.set_cell(Vector2i(x / PHYSICS_GRID_RATIO, y / PHYSICS_GRID_RATIO), 0, Vector2i(0,0))
			else:
				%PhysicsTileMap.set_cell(Vector2i(x / PHYSICS_GRID_RATIO, y / PHYSICS_GRID_RATIO), 0, Vector2i(1,0))
		# Process the value through your custom function
		var processed_value = g.sample(d / 255.0) 
		
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
	#compute_graph()
	
	#print("Updated texture with value: ", data[8])


func _on_timer_timeout() -> void:
	invalidate_path = true
