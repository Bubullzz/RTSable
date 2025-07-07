extends Node2D

@export var g : Gradient
var current_array := []

var udp := PacketPeerUDP.new()
const PORT = 5555
const WIDTH = 320
const HEIGHT = 240
var received_data := PackedByteArray()
var expecting_new_frame := false

func _ready():
    if udp.bind(PORT, "*", 1024 * 1024) != OK:
        push_error("Failed to start UDP client")
    else:
        print("Godot UDP client listening...")
    
    current_array.resize(WIDTH * HEIGHT)

    var unit = preload("res://objects/unit.tscn").instantiate().create(Teams.Team.RED, Vector2(10,10))
    add_child(unit)

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
        var processed_value = g.sample(data[i] / 256.0) 
        
        # Calculate pixel position
        var x = i % WIDTH
        var y = i / WIDTH
        
        # Set the processed pixel value (convert to 0-1 range for Color)
        processed_img.set_pixel(x, y, processed_value)
    if $Sprite2D.texture == null:
        $Sprite2D.texture = ImageTexture.create_from_image(processed_img)
    else:
        $Sprite2D.texture.update(processed_img)
    
    #print("Updated texture with value: ", data[8])
