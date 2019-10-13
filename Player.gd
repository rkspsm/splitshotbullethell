extends RigidBody2D

class_name Player

export (float) var impulse_amount = 30
export (float) var precise_movement_max_distance = 250
const DELTA_FACTOR:float = 60.0

export (float) var fire_delay = 0.2
signal weapon_fire (p_position, p_rotation)
var last_fired = fire_delay + 1

var player_cam_pos: Vector2

func _ready():
	player_cam_pos = get_viewport().get_visible_rect().size * 0.5
	
var idelta:float = 0
	
func _integrate_forces(state):
	var mpos = get_viewport().get_mouse_position()
	var mdiff = mpos - player_cam_pos
	if mdiff.length() > 0:
		rotation = mdiff.angle()
		
	var impulse_vector = Vector2()
	var impulse_origin = Vector2()
	
	if Input.is_action_pressed("ui_alt_fire"):
		if mdiff.length() > 0:
			var impulse_factor = clamp(mdiff.length(), 0, precise_movement_max_distance) / precise_movement_max_distance
			impulse_vector = mdiff.normalized() * impulse_factor * impulse_amount
			impulse_origin = state.get_transform().get_origin() - mdiff
	else:
		var hinput = 0
		if Input.is_action_pressed("ui_left"):
			hinput = -1
		elif Input.is_action_pressed("ui_right"):
			hinput = 1
			
		var vinput = 0
		if Input.is_action_pressed("ui_up"):
			vinput = -1
		elif Input.is_action_pressed("ui_down"):
			vinput = 1
			
		impulse_vector = Vector2(hinput, vinput).normalized() * impulse_amount
		impulse_origin = state.get_transform().get_origin() - impulse_vector
	
	#self.apply_impulse(position - impulse_vector, impulse_vector * delta * DELTA_FACTOR)
	if impulse_vector.length() > 0:
		self.apply_impulse(impulse_origin, impulse_vector * idelta * DELTA_FACTOR)
	idelta = 0
	

func _physics_process(delta):

	idelta += delta
		
	last_fired += delta	
	if Input.is_action_pressed("ui_fire") and (not Input.is_action_pressed("ui_alt_fire")):
		
		if last_fired > fire_delay:
			last_fired = 0
			emit_signal("weapon_fire", position, rotation)
	