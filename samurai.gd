@tool
class_name Samurai
extends Node2D


@export var direction_value := Global.DIRECTION.UP: 
	set(value):
		direction_value = value
		update_editor()

var direction: Vector2i:
	get:
		match direction_value:
			Global.DIRECTION.UP: return Vector2i.UP
			Global.DIRECTION.DOWN: return Vector2i.DOWN
			Global.DIRECTION.LEFT: return Vector2i.LEFT
			Global.DIRECTION.RIGHT: return Vector2i.RIGHT
		return Vector2i.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_play_idle_animation()


func get_map_position() -> Vector2i:
	return (position / Global.TILE_SIZE_I).floor()


func update_editor() -> void:
	_play_idle_animation()


func _play_idle_animation() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.play("idle_" + Global.direction_to_string(direction))


func move(player_map_position: Vector2i, duration: float) -> void:
	if player_map_position == get_map_position() + direction * 2:
		animated_sprite_2d.play("attack_" + Global.direction_to_string(direction))
		await create_tween().tween_property(
			self, "position", position + direction * Global.TILE_SIZE_F * 2, duration
			).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
		_play_idle_animation()
