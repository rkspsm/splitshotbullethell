extends RigidBody2D

class_name Enemy

func _ready():
	add_to_group("enemies")
	add_to_group("temporaries")
