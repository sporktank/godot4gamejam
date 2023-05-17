@tool
class_name Enemy
extends Node2D


signal movement_finished
signal reaction_finished

const SMALL_PAUSE_TIME := 0.01

@export var direction_value := Global.Direction.UP: 
	set(value):
		direction_value = value
		update_editor()

var direction: Vector2i:
	get:
		match direction_value:
			Global.Direction.UP: return Vector2i.UP
			Global.Direction.DOWN: return Vector2i.DOWN
			Global.Direction.LEFT: return Vector2i.LEFT
			Global.Direction.RIGHT: return Vector2i.RIGHT
		return Vector2i.ZERO
	set(value):
		match value:
			Vector2i.UP: direction_value = Global.Direction.UP
			Vector2i.DOWN: direction_value = Global.Direction.DOWN
			Vector2i.LEFT: direction_value = Global.Direction.LEFT
			Vector2i.RIGHT: direction_value = Global.Direction.RIGHT

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_die_offset: Marker2D = $PlayerDieOffset
@onready var hurt_box: Area2D = $HurtBox
@onready var reaction: AnimatedSprite2D = $Reaction


var is_alive := true
var reacting := false
var just_reacted := false


func _ready() -> void:
	Global.potion_exploded.connect(_on_potion_exploded)
	movement_finished.connect(_on_movement_finished)
	_play_idle_animation()


func get_map_position() -> Vector2i:
	return (position / Global.TILE_SIZE_I).floor()


func update_editor() -> void:
	_play_idle_animation()


func _play_idle_animation() -> void:
	if animated_sprite_2d:
		animated_sprite_2d.play("idle_" + Global.direction_to_string(direction))


func move(_level: Level) -> void: 
	pass


func die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")
	hurt_box.queue_free()


func _on_hurt_box_area_entered(_area: Area2D) -> void:
	die()


func _on_potion_exploded(map_position: Vector2i) -> void:
	if not is_alive:
		return
	
	var explode_direction := map_position - get_map_position()
	if explode_direction.length() == 2:
		reacting = true
		
		reaction.show()
		reaction.play("default")
		await reaction.animation_finished
		reaction.hide()
		
		direction = explode_direction / 2
		await get_tree().create_timer(0.01).timeout
		reacting = false
		just_reacted = true
		reaction_finished.emit()


func _on_movement_finished() -> void:
	just_reacted = false
