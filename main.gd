extends Node


const MENU_SCENE := preload("res://menu.tscn")
const GAME_SCENE := preload("res://game.tscn")

const TRANSITION_HALF_TIME := 0.25
const FADE_VOLUME_DB := -36.0
const FULL_VOLUME_DB := -12.0

var _loading := false
var current_scene: Node = null
var current_music: AudioStreamPlayer = null

@onready var overlay: ColorRect = $CanvasLayer/Overlay


func _ready() -> void:
	Global.level_selected.connect(_on_level_selected)
	Global.level_passed.connect(_on_level_passed)
	
	load_scene(MENU_SCENE)


func load_scene(scene: PackedScene, level_name := "", do_camera_intro := true) -> void:
	if _loading:
		return
	
	_loading = true
	get_tree().paused = true
	
	var last_music := current_music
	
	if is_instance_valid(current_scene):
		if is_instance_valid(current_music):
			create_tween().tween_property(current_music, "volume_db", FADE_VOLUME_DB, TRANSITION_HALF_TIME)
		
		await create_tween().tween_property(
			overlay, "modulate:a", 1.0, TRANSITION_HALF_TIME).from(0.0
			).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
		
		remove_child(current_scene)
		current_scene.queue_free()
	
	current_scene = scene.instantiate()
	if level_name:  # This is a bit hacky?!
		current_scene.load_level(level_name)
		current_scene.do_camera_intro = do_camera_intro
	add_child(current_scene)
	
	if level_name.begins_with("woods"):
		current_music = $Music/Woods
	elif level_name.begins_with("town"):
		current_music = $Music/Town
	elif level_name.begins_with("dungeon"):
		current_music = $Music/Dungeon
	else:
		current_music = $Music/Menu
	
	if current_music != last_music:
		if is_instance_valid(last_music):
			last_music.stop()
		current_music.volume_db = FADE_VOLUME_DB
		current_music.play()
	
	get_tree().paused = false
	create_tween().tween_property(current_music, "volume_db", FULL_VOLUME_DB, TRANSITION_HALF_TIME)
	
	await create_tween().tween_property(
		overlay, "modulate:a", 0.0, TRANSITION_HALF_TIME).from(1.0
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
	
	_loading = false
	#get_tree().paused = false


func _on_level_selected(level_name: String) -> void:
	load_scene(GAME_SCENE, level_name)


func _on_level_passed(level_name: String) -> void:
	if not Global.levels_completed.has(level_name):
		Global.levels_completed.append(level_name)
	
	var next_level_name: = ""
	match level_name:
		"woods_1": next_level_name = "woods_2"
		"woods_2": next_level_name = "woods_3"
		"woods_3": next_level_name = "woods_4"
		#"woods_4": next_level_name = "town_1"
		"town_1": next_level_name = "town_2"
		"town_2": next_level_name = "town_3"
		#"town_3": next_level_name = "dungeon_1"
		"dungeon_1": next_level_name = "dungeon_2"
		"dungeon_2": next_level_name = "dungeon_3"
	
	load_scene(GAME_SCENE if next_level_name != "" else MENU_SCENE, next_level_name)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		if not is_instance_valid(current_scene):
			get_tree().quit()
		elif current_scene is Menu:
			get_tree().quit()
		elif current_scene is Game:
			load_scene(MENU_SCENE)
	
	elif Input.is_action_just_pressed("restart"):
		if current_scene is Game:
			load_scene(GAME_SCENE, (current_scene as Game).level.level_name, false)
