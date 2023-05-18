class_name LevelPassedScreen
extends CanvasLayer


var num_kills := 0
var num_moves := 0
var num_sushi := 0

@onready var darken: ColorRect = $Darken
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var goal_label: Label = $NinePatchRect/GoalLabel
@onready var kills_label: Label = $NinePatchRect/KillsLabel
@onready var moves_label: Label = $NinePatchRect/MovesLabel
@onready var sushi_label: Label = $NinePatchRect/SushiLabel
@onready var start: Marker2D = $Start
@onready var end: Marker2D = $End
@onready var continue_button: Button = $NinePatchRect/ContinueButton


func animate_appearance() -> void:
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(darken, "modulate:a", 0.75, 0.1).set_delay(0.1)
	tween.tween_property(nine_patch_rect, "position:y", end.position.y, 0.8).from(start.position.y).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel(false)
	
	kills_label.text = "KILLS: %d" % num_kills
	moves_label.text = "MOVES: %d" % num_moves
	sushi_label.text = "SUSHI: %d" % num_sushi
	
	tween.tween_property(kills_label, "position:x", 0.0, 0.2).set_delay(0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback($Appear1.play)
	
	tween.tween_property(moves_label, "position:x", 0.0, 0.2).set_delay(0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback($Appear2.play)
	
	tween.tween_property(sushi_label, "position:x", 0.0, 0.2).set_delay(0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback($Appear3.play)
	
	await tween.finished
	continue_button.disabled = false
	continue_button.grab_focus()


func _on_continue_button_focus_entered() -> void:
	$Focus.play()


func _on_continue_button_button_down() -> void:
	if $Focus.playing:
		$Focus.stop()
	$Click.play()


func _on_continue_button_mouse_entered() -> void:
	$Focus.play()
