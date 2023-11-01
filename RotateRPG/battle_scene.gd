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

@onready var enemyBGFront = $BattleGroundSet2/BattleGround1
@onready var enemyBGTopWing = $BattleGroundSet2/BattleGround2
@onready var enemyBGBotWing = $BattleGroundSet2/BattleGround3
@onready var enemyBGBack = $BattleGroundSet2/BattleGround4

var current_unit
var current_selected_enemy = 0
var battleState = BATTLE_STATE.BASE

var unit_list = []
var player_units = []
var enemy_units = []
var is_reset = true


signal enemy_selected



func _ready():
	#playerBGFront._set_current_unit($PlayerUnits/Player)
	#playerBGTopWing._set_current_unit($PlayerUnits/Player2)
	#enemyBGFront._set_current_unit($EnemyUnits/Enemy)
	#enemyBGTopWing._set_current_unit($EnemyUnits/Enemy2)
	
	set_BG_unit_position($PlayerUnits/Player, playerBGFront)
	set_BG_unit_position($PlayerUnits/Player2, playerBGTopWing)
	set_BG_unit_position($EnemyUnits/Enemy, enemyBGFront)
	set_BG_unit_position($EnemyUnits/Enemy2, enemyBGTopWing)
	
	playerBGFront.set_current_unit_position()
	playerBGTopWing.set_current_unit_position()
	enemyBGFront.set_current_unit_position()
	enemyBGTopWing.set_current_unit_position()
	
	#$PlayerUnits/Player._set_BG(playerBGFront)
	#$PlayerUnits/Player2._set_BG(playerBGTopWing)
	#$EnemyUnits/Enemy._set_BG(enemyBGFront)
	#$EnemyUnits/Enemy2._set_BG(enemyBGTopWing)
	
	
	
	battleState = BATTLE_STATE.BASE
	
	get_all_units()
	
	set_current_unit()
	
	
	
	
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
	
func set_current_unit():
	var max_speed = 0
	print($PlayerUnits/Player.speed)
	for unit in unit_list:
		if unit.get_speed() > max_speed:
			max_speed = unit.get_speed()
			current_unit = unit
	
func _input(event):
	if event.is_action_pressed("Attack") and battleState == BATTLE_STATE.BASE and turnManager.turn == TurnManager.PLAYER_TURN:
		_on_attack_pressed()
	elif event.is_action_pressed("Rotate") and battleState == BATTLE_STATE.BASE and turnManager.turn == TurnManager.PLAYER_TURN:
		_on_rotate_pressed()
	elif event.is_action_pressed("Attack") and battleState == BATTLE_STATE.ATTACK_SELECT and turnManager.turn == TurnManager.PLAYER_TURN:
		enemy_selected.emit()
	elif event.is_action_pressed("Skill") and battleState == BATTLE_STATE.ATTACK_SELECT and turnManager.turn == TurnManager.PLAYER_TURN:
		increase_selected_enemy()
	elif event.is_action_pressed("Item") and battleState == BATTLE_STATE.ATTACK_SELECT and turnManager.turn == TurnManager.PLAYER_TURN:
		decrease_selected_enemy()
	
func increase_selected_enemy():
	current_selected_enemy += 1
	if current_selected_enemy >= len(enemy_units):
		current_selected_enemy = 0
	print("Current selected enemy: " + enemy_units[current_selected_enemy].name)

func decrease_selected_enemy():
	current_selected_enemy -= 1
	if current_selected_enemy < 0:
		current_selected_enemy = len(enemy_units) - 1
	print("Current selected enemy: " + enemy_units[current_selected_enemy].name)
	
func print_current_status():
	if playerBGFront._get_current_unit():
		print("Unit on BGFront: " + playerBGFront._get_current_unit().name)
	if playerBGTopWing._get_current_unit():
		print("Unit on BGTopWing: " + playerBGTopWing._get_current_unit().name)
	if playerBGBotWing._get_current_unit():
		print("Unit on BGBotWing: " + playerBGBotWing._get_current_unit().name)
	if playerBGBack._get_current_unit():
		print("Unit on BGBack: " + playerBGBack._get_current_unit().name)
	if enemyBGFront._get_current_unit():
		print("Unit on BGFront: " + enemyBGFront._get_current_unit().name)
	if enemyBGTopWing._get_current_unit():
		print("Unit on BGTopWing: " + enemyBGTopWing._get_current_unit().name)
	if enemyBGBotWing._get_current_unit():
		print("Unit on BGBotWing: " + enemyBGBotWing._get_current_unit().name)
	if enemyBGBack._get_current_unit():
		print("Unit on BGBack: " + enemyBGBack._get_current_unit().name)

func _on_player_turn_started():
	print("=====player turn=========")
	print(current_unit)
	print("Press D to attack, A to rotate, W for Skill, S for item.")
	battleState = BATTLE_STATE.BASE
	
	
func get_user_input():
	pass

func _on_enemy_turn_started():
	print("========enemy turn=========")
	enemy_units[0].attack_unit(player_units[0])
	turnManager.turn = TurnManager.PLAYER_TURN


func _on_attack_pressed():
	print("Player selects unit to attack")
	for unit in enemy_units:
		print(unit.name)
	
	
	print("Current selected enemy: " + enemy_units[current_selected_enemy].name)
	battleState = BATTLE_STATE.ATTACK_SELECT
	await enemy_selected
	current_unit.attack_unit(enemy_units[current_selected_enemy])
	turnManager.turn = TurnManager.ENEMY_TURN
	
	


func _on_rotate_pressed():
	rotate_units(current_unit, $PlayerUnits/Player2, current_unit._get_BG(), $PlayerUnits/Player2._get_BG())
	turnManager.turn = TurnManager.ENEMY_TURN

func rotate_units(unit1, unit2, bg1, bg2):
	unit1.move_towards(bg2.global_position)
	set_BG_unit_position(unit1, bg2)
	unit2.move_towards(bg1.global_position)
	set_BG_unit_position(unit2, bg1)
	
func set_BG_unit_position(unit, bg):
	unit._set_BG(bg)
	bg._set_current_unit(unit)
