class_name UDPManager

extends Node

signal frame_received(frame: PackedByteArray)

var udp: PacketPeerUDP = PacketPeerUDP.new()
const PORT: int = 5556
const RECEIVE_WIDTH: int = 640
const RECEIVE_HEIGHT: int = 480
const CHANNELS: int = 3
const MAX_VALUE: int = 255
const BUFFER_SIZE: int = 1024 * 1024
var expecting_new_frame: bool = false
var received_data := PackedByteArray()

func _ready():
	if udp.bind(PORT, "*", BUFFER_SIZE) != OK:
		push_error("Failed to start UDP client")
	else:
		print("Godot UDP client listening...")

func _process(_delta):
	while udp.get_available_packet_count() > 0:
		var packet: PackedByteArray = udp.get_packet()
		var packet_string: String = packet.get_string_from_ascii()
		
		if packet_string == "NEW_FRAME":
			received_data = PackedByteArray()
		elif packet_string == "END_FRAME":
			if received_data.size() == RECEIVE_WIDTH * RECEIVE_HEIGHT * CHANNELS:
				frame_received.emit(received_data)
			else:
				print("Frame size mismatch: expected ", RECEIVE_WIDTH * RECEIVE_HEIGHT * CHANNELS, " got ", received_data.size())
		else:
			received_data += packet
