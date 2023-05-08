@tool
extends Node


enum DIRECTION {UP, DOWN, LEFT, RIGHT}

const TILE_SIZE_I := 16
const TILE_SIZE_F := float(TILE_SIZE_I)

var _hack_can_reload := 0


func direction_to_string(direction: Vector2i) -> String:
	match direction.clamp(Vector2i(-1, -1), Vector2i(1, 1)):
		Vector2i.UP: return "up"
		Vector2i.DOWN: return "down"
		Vector2i.LEFT: return "left"
		Vector2i.RIGHT: return "right"
	return ""


func _input(_event: InputEvent) -> void:
	if not Engine.is_editor_hint():  # For testing.
		if Input.is_action_just_pressed("quit"): get_tree().quit()
		if Input.is_action_just_pressed("fullscreen"): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)
		if Input.is_action_just_pressed("reload_scene") and _hack_can_reload >= 5: 
			_hack_can_reload = 0
			get_tree().reload_current_scene()


func _process(delta: float) -> void:
	_hack_can_reload += 1
