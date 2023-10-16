extends Node2D

var player_
var currentBattleGround

@export var max_health = 1
@export var current_health = 1
@export var attack = 0
@export var defense = 0
@export var speed = 0



func move_towards(target_pos):
	var tween  = create_tween()
	tween.tween_property(self, "position", target_pos, 1)

func attack_unit(target_unit):
	pass

func get_speed():
	return speed
