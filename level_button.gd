extends Button


func _ready() -> void:
	if name in Global.levels_completed:
		add_theme_constant_override("outline_size", 4)
		add_theme_color_override("font_color", Color.BLACK)
		add_theme_color_override("font_focus_color", Color.BLACK)
		add_theme_color_override("font_hover_color", Color.BLACK)
		add_theme_color_override("font_outline_color", Color("cce322"))


func _on_focus_entered() -> void:
	$Focus.play()


func _on_button_down() -> void:
	if $Focus.playing:
		$Focus.stop()
	$Click.play()


func _on_mouse_entered() -> void:
	$Focus.play()
