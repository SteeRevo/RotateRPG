extends Node2D

var player_
var currentBattleGround : set = _set_BG, get = _get_BG

@export var max_health = 1 : set = _set_health, get = _get_health
@export var current_health = 1
@export var attack = 0
@export var defense = 0
@export var speed = 0



func move_towards(target_pos):
	var tween  = create_tween()
	tween.tween_property(self, "position", target_pos, 1)

func attack_unit(target_unit):
	var new_health = target_unit._get_health() - self.attack
	target_unit._set_health(new_health)
	print(target_unit.name + ': ' + str(target_unit._get_health()))
	
func _set_health(_health):
	if(_health <= max_health):
		current_health = _health
	if current_health < 0:
		print("Unit is dead")

func _get_health():
	return current_health

func get_speed():
	return speed
	
func _set_BG(BG):
	currentBattleGround = BG
	
func _get_BG():
	return currentBattleGround
