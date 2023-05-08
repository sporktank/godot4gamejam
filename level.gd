class_name Level
extends Node2D


@onready var player: Player = $Player
@onready var enemies: Node2D = $Enemies


class GameNode extends RefCounted:
	var map_position: Vector2i
	var connections: Array[GameNode] = []
	
	func _to_string() -> String:
		return "GameNode(pos=%s, num_conn=%s)" % [map_position, connections.size()]
	
	func has_connection(direction: Vector2i) -> bool:
		for node in connections:
			if node.map_position == map_position + direction:
				return true
		return false

var game_nodes: Dictionary = {}


func _ready() -> void:
	resolve_map()


func _add_game_node(map_position: Vector2i) -> GameNode:
	var result: GameNode = game_nodes.get(map_position, null)
	if not result:
		result = GameNode.new()
		result.map_position = map_position
		game_nodes[map_position] = result
	
	return result


func _add_connection(a: GameNode, b: GameNode) -> void:
	if not a.connections.has(b):
		a.connections.append(b)
	
	if not b.connections.has(a):
		b.connections.append(a)


func resolve_map() -> void:
	game_nodes.clear()
	
	for child in $Connections.get_children():
		var connection: Connection = (child as Connection)
		
		var game_node_a := _add_game_node(connection.get_map_position_a())
		var game_node_b := _add_game_node(connection.get_map_position_b())
		_add_connection(game_node_a, game_node_b)


func can_player_move(direction: Vector2i) -> bool:
	var player_position := player.get_map_position()
	var game_node: GameNode = game_nodes[player_position]
	return game_node.has_connection(direction)


func move_enemies(duration: float) -> void:
	for child in enemies.get_children():
		var samurai: Samurai = (child as Samurai)
		
		samurai.move(player.get_map_position(), duration)
