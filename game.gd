class_name Game
extends Node2D


var level: Level = null
var player: Player = null

var waiting_for_player_to_move := true
var waiting_time := 0.0
var queued_input := Vector2i.ZERO
var do_camera_intro := true
var camera_intro_finished := true

@onready var camera_2d: Camera2D = $Camera2D
var camera_log2_zoom := 0.0:
	set(value):
		if is_instance_valid(camera_2d):
			camera_2d.zoom = Vector2.ONE * pow(2.0, value)
		camera_log2_zoom = value


func _ready() -> void:
	if level == null:
		printerr("No level present so loading one by default!")
		load_level("woods_1")
	
	player = level.player
	player.finished_moving.connect(_on_player_finished_moving)
	
	if do_camera_intro:
		camera_intro_finished = false
		waiting_for_player_to_move = false
		level.hide_connections()
		await animate_camera_intro()
		await level.animate_connections()
		waiting_for_player_to_move = true
		camera_intro_finished = true


func load_level(level_name: String) -> void:
	level = load("res://levels/%s.tscn" % level_name).instantiate()
	add_child(level)


func animate_camera_intro() -> void:
	var start_position := camera_2d.global_position
	var tween: Tween
	tween = create_tween().set_parallel(true)
	tween.tween_property(camera_2d, "global_position", level.goal.global_position, 1.5).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "camera_log2_zoom", 2.0, 1.5).from(0.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	tween = create_tween().set_parallel(true)
	tween.tween_property(camera_2d, "global_position", level.player.global_position, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	tween = create_tween().set_parallel(true)
	tween.tween_property(camera_2d, "global_position", start_position, 1.5).set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "camera_log2_zoom", 0.0, 1.5).from(2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	await tween.finished


func animate_camera_finish(pos: Vector2) -> void:
	var tween: Tween
	tween = create_tween().set_parallel(true)
	tween.tween_property(camera_2d, "global_position", pos, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "camera_log2_zoom", 2.0, 0.5).from(0.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	await tween.finished


func _process(delta: float) -> void:
	if waiting_for_player_to_move:
		var can_move_up := level.can_player_move(Vector2i.UP * 2) != Global.MovementType.INVALID
		var can_move_down := level.can_player_move(Vector2i.DOWN * 2) != Global.MovementType.INVALID
		var can_move_left := level.can_player_move(Vector2i.LEFT * 2) != Global.MovementType.INVALID
		var can_move_right := level.can_player_move(Vector2i.RIGHT * 2) != Global.MovementType.INVALID
		waiting_time += delta
		if waiting_time > 0.25:
			player.show_move_hints(can_move_up, can_move_down, can_move_left, can_move_right)
		
		if not can_move_up and not can_move_down and not can_move_left and not can_move_right:
			level.player.show_restart()
		
		# TODO: This need cleaning up!
		if (Input.is_action_pressed("up") or queued_input == Vector2i.UP) and can_move_up:
			player.move(Vector2i.UP * 2, level.can_player_move(Vector2i.UP * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
		
		elif (Input.is_action_pressed("down") or queued_input == Vector2i.DOWN) and can_move_down:
			player.move(Vector2i.DOWN * 2, level.can_player_move(Vector2i.DOWN * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
		
		elif (Input.is_action_pressed("left") or queued_input == Vector2i.LEFT) and can_move_left:
			player.move(Vector2i.LEFT * 2, level.can_player_move(Vector2i.LEFT * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
		
		elif (Input.is_action_pressed("right") or queued_input == Vector2i.RIGHT) and can_move_right:
			player.move(Vector2i.RIGHT * 2, level.can_player_move(Vector2i.RIGHT * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
	
	elif camera_intro_finished:
		player.show_move_hints(false, false, false, false)
		
		if not player.is_waiting_to_interact_with_item():
			if Input.is_action_just_pressed("up"):
				queued_input = Vector2i.UP
			elif Input.is_action_just_pressed("down"):
				queued_input = Vector2i.DOWN
			elif Input.is_action_just_pressed("left"):
				queued_input = Vector2i.LEFT
			elif Input.is_action_just_pressed("right"):
				queued_input = Vector2i.RIGHT


func _on_player_finished_moving() -> void:
	if player.get_map_position() == level.get_goal_map_position():
		await do_level_passed()
	
	else:
		level.collect_items()
		if player.is_waiting_to_interact_with_item():
			await player.finished_item_interaction
		
		while level.get_num_enemies_reacting() > 0:
			await get_tree().create_timer(0.05).timeout # TODO: This is a terrible way to do this.
		
		await level.move_enemies()
		waiting_for_player_to_move = true
		waiting_time = 0.0


func do_level_passed() -> void:
	animate_camera_finish(player.global_position)
	await player.win()
	
	var level_passed: LevelPassedScreen = preload("res://level_passed_screen.tscn").instantiate()
	add_child(level_passed)
	level_passed.continue_button.pressed.connect(_on_continue_button_pressed)
	
	level_passed.num_kills = player.kill_count
	level_passed.num_moves = player.move_count
	level_passed.num_sushi = player.sushi_count
	await level_passed.animate_appearance()


func _on_continue_button_pressed() -> void:
	Global.level_passed.emit(level.level_name)
