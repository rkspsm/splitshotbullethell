extends Node2D

class_name Main

var Projectile = preload("res://Projectile.tscn")
var Enemy = preload("res://Enemy.tscn")
var Player = preload("res://Player.tscn")
var Map01 = preload("res://Map01.tscn")
var GameOver = preload("res://GameOver.tscn")

var player:Node = null
var gamemap:Node = null
var game_container:Node

func _ready():
	game_container = get_node("container/view")
	reset()

var current_score = 0
var current_health:float = 100

export (float) var wait_before_healing = 3.0
export (float) var wait_between_heals = 1.2
export (float) var multiply_consecutive_heals = 1.5
export (float) var max_heal_distance_fraction = 0.4
export (float) var damage_immunity_duration_after_hit = 0.5

var map_center: Vector2;
var heal_dist: float;
var time_elapsed: float;
var current_enemies = 1

func reset():
	time_elapsed = 0
	current_enemies = 1
	get_tree().paused = false
	get_tree().call_group("temporaries", "queue_free")
	yield(get_tree().create_timer(0.0), "timeout")
	
	if gamemap == null:
		gamemap = Map01.instance()
		game_container.add_child(gamemap)
		
	map_center = gamemap.get_map_center()
	heal_dist = gamemap.get_map_size_fraction(max_heal_distance_fraction)
		
	if player == null:
		player = Player.instance()
		game_container.add_child(player)
		
		# warning-ignore:return_value_discarded
		player.connect("weapon_fire", self, "_on_player_weapon_fire")
		# warning-ignore:return_value_discarded
		player.connect("body_entered", self, "_on_player_body_entered")
	
	player.set_position(gamemap.get_player_position())
	var first_enemy = Enemy.instance()
	first_enemy.set_position(gamemap.get_first_enemy_position())
	connect_enemy_shot(first_enemy)
	game_container.add_child(first_enemy)
	
	current_score = 0
	add_and_update_scoreboard(0)
	
	current_health = 100
	add_and_update_healthbar(0.0)
	last_heal_done = get_base_heal_amount()
	
	impulse_on_split = initial_impulse_on_split
	current_projectile_mass = initial_projectile_mass

func add_and_update_scoreboard(v:int):
	if v>0 and (not is_player_near_center()):
		return
	current_score += v
	$scoreboard/label.set_text("Score: %d" % current_score)

func add_and_update_healthbar(v:float):
	current_health = clamp(current_health + v, 0, 100)
	$healthbar/label.set_text("HP: %d %%" % current_health)
	if current_health <= 0:
		_on_gameover()
		
export (float) var initial_impulse_on_split = 100.0
export (float) var initial_projectile_mass = 0.25

func get_current_impulse_on_hit():
	#return 100.0 + current_enemies * 25
	return 500.0
	
func get_current_projectile_mass():
	#return 0.25 + current_enemies * 0.04
	return 1.0
	
func get_current_score_on_hit():
	return round(10.0 + 30 / (1 + 0.2*current_enemies))
	
func get_current_score_on_miss():
	return 5.0 + 500 / (1 + 0.5*current_enemies*current_enemies)
	
func get_current_damage():
	return 7.0 + 0.2*current_enemies

func on_projectile_score(score_sign):
	if score_sign > 0:
		add_and_update_scoreboard(get_current_score_on_hit())
	elif score_sign < 0:
		add_and_update_scoreboard(-get_current_score_on_miss())

var current_projectile_mass = initial_projectile_mass
func _on_player_weapon_fire(p_position, p_rotation):
	var projectile = Projectile.instance()
	projectile.set_mass(current_projectile_mass)
	projectile.setup(p_position, p_rotation)
	game_container.add_child(projectile)
	projectile.connect("score", self, "on_projectile_score")
	
var relative_time:float = 0
var player_just_hit:bool = false
var last_dmg_time:float = -(damage_immunity_duration_after_hit + 1)
func _on_player_body_entered(body):
	if body.is_in_group("enemies"):
		player_just_hit = true
		if relative_time - last_dmg_time > damage_immunity_duration_after_hit:
			last_dmg_time = relative_time
			add_and_update_healthbar(-get_current_damage())

var impulse_on_split = initial_impulse_on_split
func enemy_shot(body):
	if body.get_name() == "Projectile":
		if randf() < 0.4:
			var p = body.get_position()
			var daughter = Enemy.instance()
			daughter.set_position(p + body.get_linear_velocity().normalized()*25)
			var shift = Vector2(1,0).rotated(deg2rad(randi()%360))
			daughter.apply_impulse(p + shift*100, -shift*impulse_on_split) 
			yield(get_tree().create_timer(0.0), "timeout")
			current_enemies += 1
			impulse_on_split = get_current_impulse_on_hit()
			current_projectile_mass = get_current_projectile_mass()
			game_container.add_child(daughter)
			connect_enemy_shot(daughter)
	
func connect_enemy_shot(e):
	e.connect("body_entered", self, "enemy_shot")
	
var dialog_gameover = null
var dialog_gamepause = null
	
func _on_gameover():
	get_tree().paused = true
	dialog_gameover = GameOver.instance()
	dialog_gameover.get_node("label").set_text("GAME OVER ! You Scored: %d" % current_score)
	add_child(dialog_gameover)

func _input(event):
	if dialog_gameover != null:
		if event.is_action_pressed("ui_accept"):
			dialog_gameover.queue_free()
			dialog_gameover = null
			reset()
	elif dialog_gamepause != null:
		if event.is_action_pressed("ui_accept"):
			dialog_gamepause.queue_free()
			dialog_gamepause = null
			get_tree().paused = false
	elif dialog_gamepause == null:
		if event.is_action_pressed("ui_cancel"):
			dialog_gamepause = GameOver.instance()
			dialog_gamepause.get_node("label").set_text("PAUSED")
			add_child(dialog_gamepause)
			get_tree().paused = true
			
func is_player_near_center():
	var dist_from_center = (player.position - map_center).length()
	return dist_from_center <= heal_dist
			
func get_base_heal_amount():
	return 4.0 + (0.2*current_enemies)
			
var time_passed_since_last_hit:float = 0
var last_heal_done:float = get_base_heal_amount()
var time_passed_since_last_heal:float = 0
func _process(delta):
	relative_time += delta
	time_elapsed += delta
	if dialog_gameover == null and dialog_gamepause == null:
		if player_just_hit:
			player_just_hit = false
			time_passed_since_last_hit = 0
			last_heal_done = get_base_heal_amount()
			time_passed_since_last_heal = wait_before_healing + 1
		else:
			time_passed_since_last_hit += delta
			if current_health < 100 and time_passed_since_last_hit >= wait_before_healing:
				
				if (time_passed_since_last_heal < wait_between_heals) or (not is_player_near_center()):
					time_passed_since_last_heal += delta
				else:
					time_passed_since_last_heal = 0
					last_heal_done *= multiply_consecutive_heals
					add_and_update_healthbar(last_heal_done)
					
