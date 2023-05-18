@tool
class_name Skeleton
extends Enemy


const WALK_DURATION := 0.3
const TURN_DURATION := 0.1


func move(level: Level) -> void:
	if is_alive:# and level.has_connection(get_map_position(), direction * 2):
		#var will_turn := not level.has_connection(get_map_position() + direction * 2, direction * 2)
		var will_turn := false
		if not level.has_connection(get_map_position() + direction * 2, direction * 2):
			will_turn = true
		else:
			var connection := level.get_connection(get_map_position() + direction * 2, direction * 2)
			if connection.blocked:
				will_turn = true
		# TODO: Refactor above?
		
		var will_kill := level.player.get_map_position() == get_map_position() + direction * 2
		
		var dir_str := Global.direction_to_string(direction)
		var opp_dir_str := Global.direction_to_string(-direction)
		animated_sprite_2d.play("walk_" + dir_str)
		$Move.play()
		
		await create_tween().tween_property(
			self, "position", position + direction * Global.TILE_SIZE_F * 2, WALK_DURATION - (TURN_DURATION if will_turn else 0.0)
			).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
		
		if will_kill:
			level.player.die(player_die_offset.position)
			animated_sprite_2d.play("idle_down")
		
		else:
			if will_turn:
				animated_sprite_2d.play("turn_from_%s_to_%s" % [dir_str, opp_dir_str])
				await animated_sprite_2d.animation_finished
				direction *= -1
				animated_sprite_2d.play("idle_" + opp_dir_str)
			else:
				animated_sprite_2d.play("idle_" + dir_str)
		
	else: 
		await get_tree().create_timer(SMALL_PAUSE_TIME).timeout
	
	movement_finished.emit()
