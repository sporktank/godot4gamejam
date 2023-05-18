extends Node2D


var level: Level = null
var player: Player = null

var waiting_for_player_to_move := true
var queued_input := Vector2i.ZERO


func _ready() -> void:
	if level == null:
		printerr("No level present so loading one by default!")
		load_level("woods_1")
	
	player = level.player
	player.finished_moving.connect(_on_player_finished_moving)


func load_level(level_name: String) -> void:
	level = load("res://levels/%s.tscn" % level_name).instantiate()
	add_child(level)


func _process(_delta: float) -> void:
	if waiting_for_player_to_move:
		player.show_move_hints(
			level.can_player_move(Vector2i.UP * 2) != Global.MovementType.INVALID,
			level.can_player_move(Vector2i.DOWN * 2) != Global.MovementType.INVALID,
			level.can_player_move(Vector2i.LEFT * 2) != Global.MovementType.INVALID,
			level.can_player_move(Vector2i.RIGHT * 2) != Global.MovementType.INVALID
		)
		
		# TODO: This need cleaning up!
		if (Input.is_action_pressed("up") or queued_input == Vector2i.UP) and level.can_player_move(Vector2i.UP * 2) != Global.MovementType.INVALID:
			player.move(Vector2i.UP * 2, level.can_player_move(Vector2i.UP * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
		
		elif (Input.is_action_pressed("down") or queued_input == Vector2i.DOWN) and level.can_player_move(Vector2i.DOWN * 2) != Global.MovementType.INVALID:
			player.move(Vector2i.DOWN * 2, level.can_player_move(Vector2i.DOWN * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
		
		elif (Input.is_action_pressed("left") or queued_input == Vector2i.LEFT) and level.can_player_move(Vector2i.LEFT * 2) != Global.MovementType.INVALID:
			player.move(Vector2i.LEFT * 2, level.can_player_move(Vector2i.LEFT * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
		
		elif (Input.is_action_pressed("right") or queued_input == Vector2i.RIGHT) and level.can_player_move(Vector2i.RIGHT * 2) != Global.MovementType.INVALID:
			player.move(Vector2i.RIGHT * 2, level.can_player_move(Vector2i.RIGHT * 2))
			waiting_for_player_to_move = false
			queued_input = Vector2i.ZERO
	
	else:
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


func do_level_passed() -> void:
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
