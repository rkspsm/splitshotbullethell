extends Node2D

class_name Map01

var Tile = preload("res://Tile.tscn")

const TILE_SIZE = 100

export (int) var cols = 20
export (int) var rows = 20

func get_player_position() -> Vector2:
	return (Vector2(cols*0.5, rows*0.66) * TILE_SIZE)
	
func get_first_enemy_position() -> Vector2:
	return (Vector2(cols*0.5, rows*0.33) * TILE_SIZE)

func get_map_center() -> Vector2:
	return (Vector2(cols*0.5, rows*0.5)*TILE_SIZE)
	
func get_map_size_fraction(f) -> float:
	if rows>cols:
		return cols*f*TILE_SIZE
	else:
		return rows*f*TILE_SIZE

func _ready():
	for i in range(cols):
		for j in range(rows):
			var tile = Tile.instance()
			tile.tile_type = "dirt"
			add_child(tile)
			tile.translate(Vector2(i*TILE_SIZE, j*TILE_SIZE))
			
		yield(get_tree().create_timer(0.0), "timeout")
		
	for i in range(-1,cols+1):
		var wall_top = Tile.instance()
		wall_top.tile_type = "wall"
		wall_top.translate(Vector2(i*TILE_SIZE, -TILE_SIZE))
		add_child(wall_top)
		
		var wall_bottom = Tile.instance()
		wall_bottom.tile_type = "wall"
		wall_bottom.translate(Vector2(i*TILE_SIZE, rows*TILE_SIZE))
		add_child(wall_bottom)
	yield(get_tree().create_timer(0.0), "timeout")
		
	for j in range(-1,rows+1):
		var wall_left = Tile.instance()
		wall_left.tile_type = "wall"
		wall_left.translate(Vector2(-TILE_SIZE, j*TILE_SIZE))
		add_child(wall_left)
		
		var wall_right = Tile.instance()
		wall_right.tile_type = "wall"
		wall_right.translate(Vector2(cols*TILE_SIZE, j*TILE_SIZE))
		add_child(wall_right)
	
