@tool
class_name Samurai
extends Enemy


@onready var sword: Sprite2D = $AnimatedSprite2D/Sword
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_play_idle_animation()
	#if not Engine.is_editor_hint():
		#var dir_str := Global.direction_to_string(direction)
		#animated_sprite_2d.play("idle_" + dir_str)
		#animation_player.play("idle_" + dir_str)


func _play_idle_animation() -> void:
	super()
	if animation_player:
		animation_player.play("idle_" + Global.direction_to_string(direction))


func move(level: Level) -> void:
	if is_alive and level.player.get_map_position() == get_map_position() + direction * 2:
		var dir_str := Global.direction_to_string(direction)
		
		animated_sprite_2d.play("attack_" + dir_str)
		animation_player.play("idle_" + dir_str)
		await create_tween().tween_property(
			self, "position", position + direction * Global.TILE_SIZE_F * 2, 0.35
			).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
		
		# TODO: Animate sword.
		
		animated_sprite_2d.play("kill")
		animation_player.play("kill")
		level.player.die(player_die_offset.position)
		sword.show()
	
	else:
		await get_tree().create_timer(SMALL_PAUSE_TIME).timeout
	
	movement_finished.emit()


func die() -> void:
	super()
	sword.hide()
