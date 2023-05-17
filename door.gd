@tool
class_name Door
extends Connection


@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	Global.player_collected_key.connect(_on_player_connected_key)
	
	blocked = true


func _on_player_connected_key(_player: Player, _key: Key) -> void:
	blocked = false
	sprite_2d.hide()
	# TODO: Animation.
