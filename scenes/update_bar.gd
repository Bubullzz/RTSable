extends CanvasLayer

@onready var health_bar_pink: ProgressBar = $PinkHealthBar
@onready var health_bar_blue: ProgressBar = $BlueHealthBar

func _ready() -> void:
    call_deferred("defered_ready")

func defered_ready() -> void:
    GameState.blue_nexus.entity_info.connect("damaged", _blue_damaged)
    GameState.red_nexus.entity_info.connect("damaged", _pink_damaged)

func _blue_damaged(value: int) -> void:
    health_bar_blue.value = value

func _pink_damaged(value: int) -> void:
    health_bar_pink.value = value
