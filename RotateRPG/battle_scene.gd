extends Node2D

var turnManager = preload("res://TurnManager.tres")

enum BATTLE_STATE {BASE, ATTACK_SELECT, SKILL_MENU, SKILL_SELECT, ROTATE_SELECT, IN_ATTACK, IN_SKILL, IN_ROTATE}

@onready var battle_ui = $BattleUI

var current_unit

var unit_list = []
var player_units = []
var enemy_units = []


func _ready():
	$BattleGroundSet/BattleGround.set_current_unit($PlayerUnits/Player)
	$BattleGroundSet/BattleGround2.set_current_unit($PlayerUnits/Player2)
	$BattleGroundSet2/BattleGround.set_current_unit($EnemyUnits/Enemy)
	
	get_all_units()
	
	var max_speed = 0
	print($PlayerUnits/Player.speed)
	for unit in unit_list:
		if unit.get_speed() > max_speed:
			max_speed = unit.get_speed()
			current_unit = unit
	
	print(current_unit)
	
	
	turnManager.connect("player_turn_started", self._on_player_turn_started)
	turnManager.connect("enemy_turn_started", self._on_enemy_turn_started)
	

	
func get_all_units():

	for unit in $PlayerUnits.get_children():
		player_units.append(unit)
		unit_list.append(unit)
	for unit in $EnemyUnits.get_children():
		enemy_units.append(unit)
		unit_list.append(unit)

	
	print(unit_list)
	

func _on_player_turn_started():
	print("player turn")
	
func _on_enemy_turn_started():
	print("enemy turn")


func _on_attack_pressed():
	turnManager.turn = TurnManager.ENEMY_TURN


func _on_rotate_pressed():
	rotate_units(current_unit, $PlayerUnits/Player2)

func rotate_units(unit1, unit2):
	unit1.move_towards($BattleGroundSet/BattleGround2.global_position)
	unit2.move_towards($BattleGroundSet/BattleGround.global_position)
