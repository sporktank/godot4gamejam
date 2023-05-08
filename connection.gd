class_name Connection
extends Node2D


@onready var node_a: Node2D = $A
@onready var node_b: Node2D = $B


func get_map_position_a() -> Vector2i:
	return ((position + (node_a.global_position - global_position)) / 16).floor()

func get_map_position_b() -> Vector2i:
	return ((position + (node_b.global_position - global_position)) / 16).floor()
