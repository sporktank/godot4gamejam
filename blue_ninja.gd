class_name BlueNinja
extends Enemy


signal star_throw_finished

var ready_to_attack := false
var attack_direction := Vector2i.ZERO
var throwing := false

@onready var star: Sprite2D = $AnimatedSprite2D/StarBase/Star
@onready var hit_box: Area2D = $AnimatedSprite2D/StarBase/Star/HitBox


func move(level: Level) -> void:
	var rel := get_map_position() - level.player.get_map_position()
	if not is_alive:
		await get_tree().create_timer(SMALL_PAUSE_TIME).timeout
	
	elif ready_to_attack:
		#var attack_distance := 400.0
		#var tween := create_tween().set_parallel(true)
		#tween.tween_property(star, "position", star.position + attack_direction * attack_distance, 1.0)
		#tween.tween_property(star, "rotation", TAU * 10.0, 1.0)
		#await tween.finished
		throw_star()
		await star_throw_finished
		
		ready_to_attack = false
	
	elif (rel.x == 0 or rel.y == 0) and (rel != Vector2i.ZERO):
		ready_to_attack = true
		attack_direction = -rel / rel.length()
		star.position = Vector2i.ZERO
		star.rotation = 0.0
		star.show() # TODO: Animation.
		await get_tree().create_timer(SMALL_PAUSE_TIME).timeout
	
	else:
		await get_tree().create_timer(SMALL_PAUSE_TIME).timeout
	
	movement_finished.emit()


func throw_star() -> void:
	hit_box.monitorable = false
	hit_box.monitoring = false
	throwing = true


func _process(delta: float) -> void:
	if throwing:
		star.rotation += 4 * TAU * delta
		star.position += attack_direction * 256.0 * delta
		hit_box.monitorable = star.position.length() > 32  # Throw away from self before attacking anything.
		hit_box.monitoring = star.position.length() > 32  # Throw away from self before attacking anything.
		
		if not Rect2i(-20, -20, 340, 240).has_point(star.global_position):
			throwing = false
			star.hide()
			star_throw_finished.emit()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	throwing = false
	star_throw_finished.emit()
	if not area.get_parent() is Player:
		star.hide()
		star.position = Vector2i.ZERO
