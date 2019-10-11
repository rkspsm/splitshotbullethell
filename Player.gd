extends RigidBody2D

class_name Player

export (float) var impulse_amount = 30
const DELTA_FACTOR:float = 60.0

export (float) var fire_delay = 0.2
signal weapon_fire (p_position, p_rotation)
var last_fired = fire_delay + 1

var player_cam_pos: Vector2

func _ready():
	player_cam_pos = get_viewport().get_visible_rect().size * 0.5

func _physics_process(delta):
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
		
	var impulse_vector = Vector2(hinput, vinput).normalized() * impulse_amount
	
	self.apply_impulse(position - impulse_vector, impulse_vector * delta * DELTA_FACTOR)
	
	var mpos = get_viewport().get_mouse_position()
	var mdiff = mpos - player_cam_pos
	if mdiff.length() > 0:
		rotation = mdiff.angle()
		
	if Input.is_action_pressed("ui_fire"):
		last_fired += delta
		if last_fired > fire_delay:
			last_fired = 0
			emit_signal("weapon_fire", position, rotation)
	