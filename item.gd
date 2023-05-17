class_name Item
extends Node2D


var collectable := true

@onready var sprite_2d: Sprite2D = $Sprite2D


func get_map_position() -> Vector2i:
	return (position / Global.TILE_SIZE_I).floor()


func _process(_delta: float) -> void:
	sprite_2d.position.y = -8 + 2 * sin(Time.get_ticks_msec() / 1000.0 * TAU)


func collect() -> void:
	if not collectable:
		return
	
	collectable = false
	hide() # TODO: Animation.
