extends Node2D

class_name Tile

export var tile_type = "dirt"

func _ready():
	$tiles.stop()
	if tile_type == "wall":
		$wall.set_visible(true)
		get_node("wall_physics/wall_shape").set_disabled(false)
		$wall_physics.add_to_group("wall")
	else:
		$tiles.set_visible(true)
		var frame_count = $tiles.frames.get_frame_count(tile_type)
		if frame_count > 0:
			var frame_index = randi()%frame_count
			$tiles.set_animation(tile_type)
			$tiles.set_frame(frame_index)
