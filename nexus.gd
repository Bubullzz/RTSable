extends StaticBody2D


@export var health : int
@export var team : Teams.Team
    

func _on_timer_timeout() -> void:
    var unit = preload("res://objects/unit.tscn").instantiate().create(team, Vector2(10,10))
    add_child(unit)
    print("Unit created at position: ", unit.global_position)
    pass # Replace with function body.
