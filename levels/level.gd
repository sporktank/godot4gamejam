class_name Level
extends Node2D


@onready var level_name := scene_file_path.get_file().replace(".tscn", "")

@onready var player: Player = $Player
@onready var enemies: Node2D = $Enemies
@onready var goal: Marker2D = $Goal
@onready var items: Node2D = $Items


# TODO: Merge this into Connection.
class GameNode extends RefCounted:
	var map_position: Vector2i
	var connections: Array[GameNode] = []
	
	func _to_string() -> String:
		return "GameNode(pos=%s, num_conn=%s)" % [map_position, connections.size()]
	
	func has_connection(direction: Vector2i) -> bool:  # TODO: Perhaps to/from is better?
		for node in connections:
			if node.map_position == map_position + direction:
				return true
		return false

var game_nodes: Dictionary = {}
var connections_map: Dictionary = {}


func _ready() -> void:
	resolve_map()


func _add_game_node(map_position: Vector2i) -> GameNode:
	var result: GameNode = game_nodes.get(map_position, null)
	if not result:
		result = GameNode.new()
		result.map_position = map_position
		game_nodes[map_position] = result
	
	return result


func _add_connection(a: GameNode, b: GameNode, connection: Connection) -> void:
	if not a.connections.has(b):
		a.connections.append(b)
	
	if not b.connections.has(a):
		b.connections.append(a)
	
	connections_map[Vector4i(a.map_position.x, a.map_position.y, b.map_position.x, b.map_position.y)] = connection
	connections_map[Vector4i(b.map_position.x, b.map_position.y, a.map_position.x, a.map_position.y)] = connection


func resolve_map() -> void:
	game_nodes.clear()
	
	for child in $Connections.get_children():
		var connection: Connection = (child as Connection)
		
		var game_node_a := _add_game_node(connection.get_map_position_a())
		var game_node_b := _add_game_node(connection.get_map_position_b())
		_add_connection(game_node_a, game_node_b, connection)


func get_goal_map_position() -> Vector2i:
	return (goal.position / Global.TILE_SIZE_I).floor()


func can_player_move(direction: Vector2i) -> Global.MovementType:
	if not player.can_move:
		return Global.MovementType.INVALID
	
	var player_position := player.get_map_position()
	var destination := player_position + direction
	
	# If no node exists at that point, definitely can't move.
	var game_node: GameNode = game_nodes[player_position]
	if not game_node.has_connection(direction):
		return Global.MovementType.INVALID
	
	# Get the relevant connection scene.
	var key := Vector4i(
		player_position.x,
		player_position.y,
		destination.x,
		destination.y
	)
	var connection: Connection = (connections_map[key] as Connection)
	assert(connection)
	
	# If blocked, cannot move through.
	if connection.blocked:
		return Global.MovementType.INVALID
	
	# If not enemy, okay to move.
	if not has_enemy(player_position + direction):
		return Global.MovementType.MOVE
	
	# If enemy is dead then can proceed.
	var enemy := get_enemy(player_position + direction)
	if not enemy.is_alive:
		return Global.MovementType.MOVE
	
	# If enemy and sword then can attack.
	if player.has_sword:
		return Global.MovementType.ATTACK
	
	# Otherwise assume can't move, usually into an enemy.
	return Global.MovementType.INVALID


func has_enemy(map_position: Vector2i) -> bool:
	for child in enemies.get_children():
		var enemy := (child as Enemy)
		
		if enemy.get_map_position() == map_position:
			return true
	
	return false


func get_enemy(map_position: Vector2i) -> Enemy:
	for child in enemies.get_children():
		var enemy := (child as Enemy)
		
		if enemy.get_map_position() == map_position:
			return enemy
	
	return null


func has_connection(from: Vector2i, direction: Vector2i) -> bool:
	if not game_nodes.has(from):
		return false
	return game_nodes[from].has_connection(direction)


func get_connection(from: Vector2i, direction: Vector2i) -> Connection:
	var destination := from + direction
	var key := Vector4i(
		from.x,
		from.y,
		destination.x,
		destination.y
	)
	return connections_map[key] as Connection


# HACKY: Is there a better way to do this?
signal _all_enemy_movement_finished
var _expected_move_enemies := 0
var _num_move_enemies := 0
func _count_move_enemies() -> void:
	_num_move_enemies += 1
	if _num_move_enemies >= _expected_move_enemies:
		_all_enemy_movement_finished.emit()
# ...
func move_enemies() -> void:
	if enemies.get_child_count() == 0:
		return
	
	_num_move_enemies = 0
	_expected_move_enemies = enemies.get_child_count()
	
	for child in enemies.get_children():
		var enemy: Enemy = (child as Enemy)
		
		enemy.movement_finished.connect(_count_move_enemies)
		enemy.move(self)
	
	await _all_enemy_movement_finished
	
	for child in enemies.get_children():
		var enemy: Enemy = (child as Enemy)
		enemy.movement_finished.disconnect(_count_move_enemies)


func collect_items() -> void:
	for child in items.get_children():
		var item := (child as Item)
		
		if item.collectable and item.get_map_position() == player.get_map_position():
			player.collect(item)


func _on_player_attacked_position(map_position: Vector2i) -> void:
	for child in enemies.get_children():
		var enemy: Enemy = (child as Enemy)
		
		if enemy.get_map_position() == map_position:
			enemy.die()
			player.kill_count += 1


func _on_player_attacking_position(map_position: Vector2i) -> void:
	for child in enemies.get_children():
		var enemy: Enemy = (child as Enemy)
		
		if enemy.get_map_position() == map_position:
			create_tween().tween_callback(enemy.bleed).set_delay(player.MOVE_DURATION * 0.4)


func get_num_enemies_reacting() -> int:
	var count := 0
	for child in enemies.get_children():
		var enemy: Enemy = (child as Enemy)
		if enemy.reacting:
			count += 1
	return count


func hide_connections() -> void:
	for child in $Connections.get_children():
		var connection := child as Connection
		connection.hide()


func animate_connections() -> void:
	var tween := create_tween().set_parallel(true)
	
	for child in $Connections.get_children():
		var connection := child as Connection
		
		connection.modulate.a = 0.0
		connection.show()
		
		var distance := player.global_position.distance_to(connection.global_position)
		var delay := distance / 32.0 * 0.1
		tween.tween_property(connection, "modulate:a", 1.0, 0.2).set_delay(delay)
		tween.tween_callback(connection.appear.play).set_delay(delay)
	
	await tween.finished
