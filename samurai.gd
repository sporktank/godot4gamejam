@tool
class_name Samurai
extends Enemy


@onready var sword: Sprite2D = $Sword


func move(level: Level) -> void:
	if is_alive and level.player.get_map_position() == get_map_position() + direction * 2:
		animated_sprite_2d.play("attack_" + Global.direction_to_string(direction))
		await create_tween().tween_property(
			self, "position", position + direction * Global.TILE_SIZE_F * 2, 0.35
			).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
		
		# TODO: Animate sword.
		
		animated_sprite_2d.play("idle_down")
		level.player.die(player_die_offset.position)
		sword.show()
	
	else:
		await get_tree().create_timer(SMALL_PAUSE_TIME).timeout
	
	movement_finished.emit()
