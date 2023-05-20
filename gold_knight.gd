@tool
class_name GoldKnight
extends Enemy


@onready var weapon: Sprite2D = $AnimatedSprite2D/Weapon
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _play_idle_animation() -> void:
	super()
	if animation_player:
		animation_player.play("idle_" + Global.direction_to_string(direction))


func move(level: Level) -> void:
	if not is_alive or just_reacted:
		await get_tree().create_timer(SMALL_PAUSE_TIME).timeout
	
	else:
		if level.player.get_map_position() == get_map_position() + direction * 2:
			animated_sprite_2d.play("attack_" + Global.direction_to_string(direction))
			await create_tween().tween_property(
				self, "position", position + direction * Global.TILE_SIZE_F * 2, 0.35
				).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).finished
			
			# TODO: Animate sword.
			
			animated_sprite_2d.play("kill")
			animation_player.play("kill")
			level.player.die(player_die_offset.position)
			
		else:
			var dir_str := Global.direction_to_string(direction)
			var opp_dir_str := Global.direction_to_string(-direction)
			
			weapon.hide()
			animation_player.play("idle_" + opp_dir_str)
			animated_sprite_2d.play("turn_from_%s_to_%s" % [dir_str, opp_dir_str])
			$Move.play()
			await animated_sprite_2d.animation_finished
			weapon.show()
			direction *= -1
	
	movement_finished.emit()


func die() -> void:
	super()
	weapon.hide()
 
