extends Area2D
@onready var collision: CollisionShape2D = $HurtBoxShape

@export_range(0, 10, .1) var hurt_box_radius: float        

func _ready() -> void:
    collision.shape.radius = hurt_box_radius

func _on_body_entered(body:Node2D) -> void:
    print("Body entered: ", body.name)
    if body is Projectile:
        get_parent().entity_info.on_hit(body.damage)
        #body.queue_free()
