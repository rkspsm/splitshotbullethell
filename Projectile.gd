extends RigidBody2D

class_name Projectile

func _ready():
	add_to_group("projectiles")
	add_to_group("temporaries")

func setup(p_position:Vector2, p_rotation:float):
	position = p_position + Vector2(50,0).rotated(p_rotation)
	rotation = p_rotation
	apply_impulse(p_position, Vector2(2500,0).rotated(p_rotation))

signal score (v)

func _on_Projectile_body_entered(body):
	if body.is_in_group("wall"):
		emit_signal("score", -1)
	if body.is_in_group("enemies"):
		emit_signal("score", 1)
	queue_free()
