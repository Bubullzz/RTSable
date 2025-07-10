extends Node

var camera : CVCamera = CVCamera.new();
@export var OO : Sprite2D;
var texture : ImageTexture;
var coordinates : Vector2;

func _ready():
	camera.open(0, 1920, 1080);
	camera.flip(true, false);
	texture = ImageTexture.new();

func _process(delta):
	texture.set_image(camera.get_image());
	coordinates = camera.get_coordinates();
	print(coordinates);
