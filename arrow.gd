class_name Arrow
extends Sprite2D


signal finished_shooting_arrow


func _process(delta: float) -> void:
	var direction := Vector2.from_angle(rotation)
	position += direction * 384.0 * delta
	
	if not Rect2i(-20, -20, 340, 240).has_point(global_position):
		finished_shooting_arrow.emit()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	finished_shooting_arrow.emit()
