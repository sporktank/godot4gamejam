class_name PotionExplosion
extends Node2D


var direction: Vector2i

@onready var potion: Sprite2D = $Potion
@onready var explosion: AnimatedSprite2D = $Explosion


func get_map_position() -> Vector2i:
	return (global_position / Global.TILE_SIZE_I).floor()


func throw_and_explode() -> void:
	#print("throw and explode in direction ", direction)
	#await get_tree().create_timer(1).timeout
	
	var half_duration := 0.3
	create_tween().tween_property(self, "position", position + 2 * direction * Global.TILE_SIZE_F, 2 * half_duration).set_trans(Tween.TRANS_LINEAR)
	var tween := create_tween()
	tween.tween_property(potion, "position:y", -16.0, half_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(potion, "position:y", 0.0, half_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	
	potion.hide()
	explosion.show()
	explosion.play("default")
	await explosion.animation_finished
	
	Global.potion_exploded.emit(get_map_position())
