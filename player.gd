class_name Player
extends Node2D


signal finished_moving
signal attacked_position(map_position: Vector2i)
signal finished_item_interaction

const MOVE_DURATION := 0.4

var can_move := true
var has_sword := false
var sushi_count := 0
var move_count := 0
var kill_count := 0
var has_key := false
var holding_bow_and_arrow := false
var arrow: Arrow = null
var holding_potion := false
var potion_explosion: PotionExplosion = null

@onready var shadow: Sprite2D = $Shadow
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword: Sprite2D = $Sword
@onready var arrow_hints: Node2D = $ArrowHints
@onready var potion_hints: Node2D = $PotionHints


func _ready() -> void:
	animated_sprite_2d.play("idle_down")


func get_map_position() -> Vector2i:
	return (position / Global.TILE_SIZE_I).floor()


func move(direction: Vector2i, movement_type: Global.MovementType = Global.MovementType.MOVE) -> void:
	#print("player moving with movement type: ", movement_type)
	move_count += 1
	
	var dir_str := Global.direction_to_string(direction)
	animated_sprite_2d.play("walk_" + dir_str)
	
	# TODO: Attack animation.
	await create_tween().tween_property(
		self, "position", position + direction * Global.TILE_SIZE_F, MOVE_DURATION
		).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
	
	if movement_type == Global.MovementType.ATTACK:
		attacked_position.emit(get_map_position())
	
	animated_sprite_2d.play("idle_" + dir_str)
	finished_moving.emit()


func die(offset: Vector2) -> void:
	can_move = false
	
	shadow.hide()
	sword.hide()
	animated_sprite_2d.play("dead")
	create_tween().tween_property(animated_sprite_2d, "position", offset + Vector2(0, -2), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	create_tween().tween_property(self, "position:y", position.y + 2, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	# TODO: Particle effects.


func win() -> void:
	can_move = false
	animated_sprite_2d.play("win")
	# TODO: Particle effects?
	
	await animated_sprite_2d.animation_finished


func collect(item: Item) -> void:
	item.collect()
	
	if item is Sword:
		equip_sword()
	
	elif item is Sushi:
		sushi_count += 1
	
	elif item is Key:
		has_key = true
		Global.player_collected_key.emit(self, item)
	
	elif item is BowAndArrow:
		holding_bow_and_arrow = true
		arrow_hints.show()
	
	elif item is Potion:
		holding_potion = true
		potion_hints.show()


func is_waiting_to_interact_with_item() -> bool:
	return holding_bow_and_arrow or holding_potion


func equip_sword() -> void:
	sword.show()
	has_sword = true


func _process(_delta: float) -> void:
	if holding_bow_and_arrow:
		arrow_hints.scale = Vector2.ONE * (1.1 + 0.1 * sin(Time.get_ticks_msec() / 1000.0 * TAU))
		
		if arrow == null:
			if Input.is_action_just_pressed("up"):
				shoot_arrow(Vector2i.UP)
			elif Input.is_action_just_pressed("down"):
				shoot_arrow(Vector2i.DOWN)
			elif Input.is_action_just_pressed("left"):
				shoot_arrow(Vector2i.LEFT)
			elif Input.is_action_just_pressed("right"):
				shoot_arrow(Vector2i.RIGHT)
	
	elif holding_potion:
		# TODO: Different animation.
		potion_hints.scale = Vector2.ONE * (1.1 + 0.1 * sin(Time.get_ticks_msec() / 1000.0 * TAU))
		
		if potion_explosion == null:
			if Input.is_action_just_pressed("up"):
				throw_potion(Vector2i.UP)
			elif Input.is_action_just_pressed("down"):
				throw_potion(Vector2i.DOWN)
			elif Input.is_action_just_pressed("left"):
				throw_potion(Vector2i.LEFT)
			elif Input.is_action_just_pressed("right"):
				throw_potion(Vector2i.RIGHT)


func shoot_arrow(direction: Vector2i) -> void:
	arrow_hints.hide()
	
	arrow = preload("res://arrow.tscn").instantiate() as Arrow
	arrow.position = arrow_hints.get_node(Global.direction_to_string(direction)).position
	arrow.rotation = arrow_hints.get_node(Global.direction_to_string(direction)).rotation
	add_child(arrow)
	
	await arrow.finished_shooting_arrow
	
	finished_item_interaction.emit()
	holding_bow_and_arrow = false
	arrow.queue_free()


func throw_potion(direction: Vector2i) -> void:
	potion_hints.hide()
	
	potion_explosion = preload("res://potion_explosion.tscn").instantiate() as PotionExplosion
	potion_explosion.direction = direction
	add_child(potion_explosion)
	
	await potion_explosion.throw_and_explode()
	
	finished_item_interaction.emit()
	holding_potion = false
	potion_explosion.queue_free()


func _on_hurt_box_area_entered(_area: Area2D) -> void:
	die(Vector2i.ZERO)
