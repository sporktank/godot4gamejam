extends Control


func _ready() -> void:
	#$Woods/Woods1.grab_focus()
	$Woods/Woods4.grab_focus()


func _on_woods_1_pressed() -> void: Global.level_selected.emit("woods_1")
func _on_woods_2_pressed() -> void: Global.level_selected.emit("woods_2")
func _on_woods_3_pressed() -> void: Global.level_selected.emit("woods_3")
func _on_woods_4_pressed() -> void: Global.level_selected.emit("woods_4")


func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_fullscreen_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)
