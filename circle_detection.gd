extends Node

var camera : CVCamera = CVCamera.new();
@export var CameraCanvas : Sprite2D;
var texture : ImageTexture;
var coordinates : Vector2;

func _ready():
	camera.open();
	camera.flip(true, false);
	texture = ImageTexture.new();

func _process(delta):
	texture.set_image(camera.get_image());
	coordinates = camera.get_coordinates();
	print(coordinates);
