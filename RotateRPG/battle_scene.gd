extends Node2D

var turnManager = preload("res://TurnManager.tres")

#battlestates
enum BATTLE_STATE {BASE, ATTACK_SELECT, SKILL_MENU, SKILL_SELECT, ROTATE_SELECT, IN_ATTACK, IN_SKILL, IN_ROTATE}

#set battlegrounds
@onready var battle_ui = $BattleUI
@onready var playerBGFront = $BattleGroundSet/BattleGround
@onready var playerBGTopWing = $BattleGroundSet/BattleGround2
@onready var playerBGBotWing = $BattleGroundSet/BattleGround3
@onready var playerBGBack = $BattleGroundSet/BattleGround4

@onready var enemyBGFront = $BattleGroundSet2/BattleGround
@onready var enemyBGTopWing = $BattleGroundSet2/BattleGround2
@onready var enemyBGBotWing = $BattleGroundSet2/BattleGround3
@onready var enemyBGBotBack = $BattleGroundSet2/BattleGround4

var current_unit

var unit_list = []
var player_units = []
var enemy_units = []




func _ready():
	playerBGFront.set_current_unit($PlayerUnits/Player)
	playerBGTopWing.set_current_unit($PlayerUnits/Player2)
	enemyBGFront.set_current_unit($EnemyUnits/Enemy)
	
	get_all_units()
	
	var max_speed = 0
	print($PlayerUnits/Player.speed)
	for unit in unit_list:
		if unit.get_speed() > max_speed:
			max_speed = unit.get_speed()
			current_unit = unit
	
	print(current_unit)
	print("Press D to attack, A to rotate, W for Skill, S for item.")
	
	
	turnManager.connect("player_turn_started", self._on_player_turn_started)
	turnManager.connect("enemy_turn_started", self._on_enemy_turn_started)
	
	turnManager.turn = TurnManager.PLAYER_TURN


	
func get_all_units():

	for unit in $PlayerUnits.get_children():
		player_units.append(unit)
		unit_list.append(unit)
	for unit in $EnemyUnits.get_children():
		enemy_units.append(unit)
		unit_list.append(unit)

	
	#print(unit_list)
	print_current_status()
	
func _input(event):
	pass
	
func print_current_status():
	if playerBGFront.get_current_unit():
		print("Unit on BGFront: " + playerBGFront.get_current_unit().name)
	if playerBGTopWing.get_current_unit():
		print("Unit on BGTopWing: " + playerBGTopWing.get_current_unit().name)
	if playerBGBotWing.get_current_unit():
		print("Unit on BGBotWing: " + playerBGBotWing.get_current_unit().name)
	if playerBGBack.get_current_unit():
		print("Unit on BGBack: " + playerBGBack.get_current_unit().name)

func _on_player_turn_started():
	print("player turn")
	#await 
	
func get_user_input():
	pass

func _on_enemy_turn_started():
	print("enemy turn")
	enemy_units[0].attack_unit(player_units[0])
	turnManager.turn = TurnManager.PLAYER_TURN


func _on_attack_pressed():
	turnManager.turn = TurnManager.ENEMY_TURN


func _on_rotate_pressed():
	rotate_units(current_unit, $PlayerUnits/Player2, playerBGFront, playerBGTopWing)
	turnManager.turn = TurnManager.ENEMY_TURN

func rotate_units(unit1, unit2, bg1, bg2):
	unit1.move_towards(bg2.global_position)
	unit2.move_towards(bg1.global_position)
