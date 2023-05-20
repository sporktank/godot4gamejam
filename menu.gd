class_name Menu
extends Control


const VOLUME_OFF := -80.0
const VOLUME_LOW := -12.0
const VOLUME_MED := -6.0
const VOLUME_HIGH := 0.0

const MUSIC_OFF := "MUSIC: OFF "
const MUSIC_LOW := "MUSIC: LOW"
const MUSIC_MED := "MUSIC: MED"
const MUSIC_HIGH := "MUSIC: HIGH"

const SOUND_OFF := "SFX: OFF"
const SOUND_LOW := "SFX: LOW "
const SOUND_MED := "SFX: MED "
const SOUND_HIGH := "SFX: HIGH "

@onready var sound_button: Button = $SoundButton
@onready var music_button: Button = $MusicButton


func _ready() -> void:
	$Woods/woods_1.grab_focus()
	#$Woods/Woods4.grab_focus()
	#$Town/Town1.grab_focus()
	
	match AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")):
		VOLUME_OFF: music_button.text = MUSIC_OFF
		VOLUME_LOW: music_button.text = MUSIC_LOW
		VOLUME_MED: music_button.text = MUSIC_MED
		VOLUME_HIGH: music_button.text = MUSIC_HIGH
	
	match AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sound")):
		VOLUME_OFF: sound_button.text = SOUND_OFF
		VOLUME_LOW: sound_button.text = SOUND_LOW
		VOLUME_MED: sound_button.text = SOUND_MED
		VOLUME_HIGH: sound_button.text = SOUND_HIGH


func _on_woods_1_pressed() -> void: Global.level_selected.emit("woods_1")
func _on_woods_2_pressed() -> void: Global.level_selected.emit("woods_2")
func _on_woods_3_pressed() -> void: Global.level_selected.emit("woods_3")
func _on_woods_4_pressed() -> void: Global.level_selected.emit("woods_4")

func _on_town_1_pressed() -> void: Global.level_selected.emit("town_1")
func _on_town_2_pressed() -> void: Global.level_selected.emit("town_2")
func _on_town_3_pressed() -> void: Global.level_selected.emit("town_3")

func _on_dungeon_1_pressed() -> void: Global.level_selected.emit("dungeon_1")
func _on_dungeon_2_pressed() -> void: Global.level_selected.emit("dungeon_2")
func _on_dungeon_3_pressed() -> void: Global.level_selected.emit("dungeon_3")


func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_fullscreen_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_WINDOWED)


# Poorman's volume sliders!
func _on_music_button_pressed() -> void:
	match music_button.text: # Some hackiness going on here, spaces added because rendering of the font looks wrong if they are not added.
		MUSIC_OFF:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), VOLUME_LOW)
			music_button.text = MUSIC_LOW
		MUSIC_LOW:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), VOLUME_MED)
			music_button.text = MUSIC_MED
		MUSIC_MED:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), VOLUME_HIGH)
			music_button.text = MUSIC_HIGH
		MUSIC_HIGH:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), VOLUME_OFF)
			music_button.text = MUSIC_OFF
func _on_sound_button_pressed() -> void:
	match sound_button.text: # Some hackiness going on here, spaces added because rendering of the font looks wrong if they are not added.
		SOUND_OFF:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound"), VOLUME_LOW)
			sound_button.text = SOUND_LOW
		SOUND_LOW:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound"), VOLUME_MED)
			sound_button.text = SOUND_MED
		SOUND_MED:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound"), VOLUME_HIGH)
			sound_button.text = SOUND_HIGH
		SOUND_HIGH:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound"), VOLUME_OFF)
			sound_button.text = SOUND_OFF
