class_name Player
extends Node2D


signal finished_moving

const WALK_DURATION := 0.4

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func get_map_position() -> Vector2i:
	return (position / Global.TILE_SIZE_I).floor()


func move(direction: Vector2i) -> void:
	var dir_str := Global.direction_to_string(direction)
	animated_sprite_2d.play("walk_" + dir_str)
	
	await create_tween().tween_property(
		self, "position", position + direction * Global.TILE_SIZE_F, WALK_DURATION
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
	
	animated_sprite_2d.play("idle_" + dir_str)
	#animated_sprite_2d.pause()
	finished_moving.emit()
