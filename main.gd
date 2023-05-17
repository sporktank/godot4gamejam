extends Node


const MENU_SCENE := preload("res://menu.tscn")
const GAME_SCENE := preload("res://game.tscn")

const TRANSITION_HALF_TIME := 0.25

var _loading := false
var current_scene: Node = null

@onready var overlay: ColorRect = $CanvasLayer/Overlay


func _ready() -> void:
	Global.level_selected.connect(_on_level_selected)
	Global.level_passed.connect(_on_level_passed)
	
	load_scene(MENU_SCENE)


func load_scene(scene: PackedScene, level_name := "") -> void:
	if _loading:
		return
	
	_loading = true
	get_tree().paused = true
	
	if is_instance_valid(current_scene):
		await create_tween().tween_property(
			overlay, "modulate:a", 1.0, TRANSITION_HALF_TIME).from(0.0
			).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
		
		remove_child(current_scene)
		current_scene.queue_free()
	
	current_scene = scene.instantiate()
	if level_name:  # This is a bit hacky?!
		current_scene.load_level(level_name)
	add_child(current_scene)
	
	await create_tween().tween_property(
		overlay, "modulate:a", 0.0, TRANSITION_HALF_TIME).from(1.0
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
	
	_loading = false
	get_tree().paused = false


func _on_level_selected(level_name: String) -> void:
	load_scene(GAME_SCENE, level_name)


func _on_level_passed(level_name: String) -> void:
	var next_level_name: = ""
	match level_name:
		"woods_1": next_level_name = "woods_2"
	
	load_scene(GAME_SCENE if next_level_name != "" else MENU_SCENE, next_level_name)
