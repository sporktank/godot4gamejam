extends Node2D


var level: Level = null
var player: Player = null

var waiting_for_player_to_move := true


func _ready() -> void:
	level = $Level
	player = level.player
	
	player.finished_moving.connect(_on_player_finished_moving)


func _input(_event: InputEvent) -> void:
	if waiting_for_player_to_move:
		if Input.is_action_pressed("up") and level.can_player_move(Vector2i.UP * 2):
			player.move(Vector2i.UP * 2)
			waiting_for_player_to_move = false
		elif Input.is_action_pressed("down") and level.can_player_move(Vector2i.DOWN * 2):
			player.move(Vector2i.DOWN * 2)
			waiting_for_player_to_move = false
		elif Input.is_action_pressed("left") and level.can_player_move(Vector2i.LEFT * 2):
			player.move(Vector2i.LEFT * 2)
			waiting_for_player_to_move = false
		elif Input.is_action_pressed("right") and level.can_player_move(Vector2i.RIGHT * 2):
			player.move(Vector2i.RIGHT * 2)
			waiting_for_player_to_move = false


func _on_player_finished_moving() -> void:
	await move_enemies()
	waiting_for_player_to_move = true


func move_enemies() -> void:
	level.move_enemies(0.3)
	await get_tree().create_timer(0.3).timeout
