extends Node2D

var turnManager = preload("res://TurnManager.tres")

#battlestates
enum BATTLE_STATE {BASE, ATTACK_SELECT, SKILL_MENU, SKILL_SELECT, ROTATE_SELECT, IN_ATTACK, IN_SKILL, IN_ROTATE, ATTACK_COMMIT}

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

var current_selected_ally
var current_unit
var current_selected_enemy 
var battleState = BATTLE_STATE.BASE

var unit_list = []
var player_units = []
var enemy_units = []
var is_reset = true

var player_index = 0
var enemy_index = 0


signal enemy_selected



func _ready():
	
	set_BG_unit_position($PlayerUnits/Sanazaki, playerBGFront)
	set_BG_unit_position($PlayerUnits/Leo, playerBGTopWing)
	set_BG_unit_position($EnemyUnits/Enemy, enemyBGFront)
	set_BG_unit_position($EnemyUnits/Enemy2, enemyBGTopWing)
	
	
	playerBGFront.set_current_unit_position()
	playerBGTopWing.set_current_unit_position()
	enemyBGFront.set_current_unit_position()
	enemyBGTopWing.set_current_unit_position()
	
	current_selected_enemy = $EnemyUnits/Enemy
	
	
	battleState = BATTLE_STATE.BASE
	
	get_all_units()
	
	set_current_unit()
	
	
	
	
	turnManager.connect("player_turn_started", self._on_player_turn_started)
	turnManager.connect("enemy_turn_started", self._on_enemy_turn_started)
	turnManager.connect("determine_next_turn", self._determine_next_turn)
	
	turnManager.turn = TurnManager.PLAYER_TURN


func insert_sort(lst, unit, action_weight):
	for i in range(len(lst)):
		if lst[i]._get_speed() < unit.get_turn_order_speed(action_weight):
			lst.insert(i, unit)
			return lst
	lst.append(unit)
	print(lst)
	return lst

func get_all_units():
	for unit in $PlayerUnits.get_children():
		insert_sort(player_units, unit, 0)
		unit_list.append(unit)
	for unit in $EnemyUnits.get_children():
		insert_sort(enemy_units, unit, 0)
		unit_list.append(unit)

	
	print(unit_list)
	print_current_status()
	
func set_current_unit():
	if player_units[0]._get_speed() >= enemy_units[0]._get_speed():
		current_unit = player_units[0]
	else:
		current_unit = enemy_units[0]
	
func _input(event):
	if event.is_action_pressed("Attack") and battleState == BATTLE_STATE.BASE and turnManager.turn == TurnManager.PLAYER_TURN:
		_on_attack_pressed()
	elif event.is_action_pressed("Rotate") and battleState == BATTLE_STATE.BASE and turnManager.turn == TurnManager.PLAYER_TURN:
		_on_rotate_pressed()
	elif event.is_action_pressed("Attack") and battleState == BATTLE_STATE.ATTACK_SELECT and turnManager.turn == TurnManager.PLAYER_TURN:
		set_current_selected_enemy(enemyBGBack._get_current_unit())
	elif event.is_action_pressed("Skill") and battleState == BATTLE_STATE.ATTACK_SELECT and turnManager.turn == TurnManager.PLAYER_TURN:
		set_current_selected_enemy(enemyBGTopWing._get_current_unit())
	elif event.is_action_pressed("Item") and battleState == BATTLE_STATE.ATTACK_SELECT and turnManager.turn == TurnManager.PLAYER_TURN:
		set_current_selected_enemy(enemyBGBotWing._get_current_unit())
	elif event.is_action_pressed("Rotate") and battleState == BATTLE_STATE.ATTACK_SELECT and turnManager.turn == TurnManager.PLAYER_TURN:
		set_current_selected_enemy(enemyBGFront._get_current_unit())
	elif event.is_action_pressed("Attack") and battleState == BATTLE_STATE.ATTACK_COMMIT and turnManager.turn == TurnManager.PLAYER_TURN:
		enemy_selected.emit()
	elif event.is_action_pressed("Rotate") and battleState == BATTLE_STATE.ATTACK_COMMIT and turnManager.turn == TurnManager.PLAYER_TURN:
		battleState = BATTLE_STATE.ATTACK_SELECT
		print("Current selected enemy: " + current_selected_enemy.name)
	
#func increase_selected_enemy():
#	current_selected_enemy += 1
#	if current_selected_enemy >= len(enemy_units):
#		current_selected_enemy = 0
#	print("Current selected enemy: " + enemy_units[current_selected_enemy].name)

#func decrease_selected_enemy():
#	current_selected_enemy -= 1
#	if current_selected_enemy < 0:
#		current_selected_enemy = len(enemy_units) - 1
#	print("Current selected enemy: " + enemy_units[current_selected_enemy].name)
	
func set_current_selected_enemy(enemy):
	if enemy != null:
		current_selected_enemy = enemy
	else:
		print("No Enemy Here")
	print("Current selected enemy: " + current_selected_enemy.name)
	print("A to back out, D to commit")
	battleState = BATTLE_STATE.ATTACK_COMMIT
	
	
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
	print("Current Unit is: " + current_unit.name)
	print("Press D to attack, A to rotate, W for Skill, S for item.")
	battleState = BATTLE_STATE.BASE
	


func _on_enemy_turn_started():
	print("========enemy turn=========")
	enemy_units[0].attack_unit(player_units[0])
	turnManager.turn = TurnManager.PLAYER_TURN


func _on_attack_pressed():
	print("Player selects unit to attack")
	for unit in enemy_units:
		print(unit.name)
	
	print("Current selected enemy: " + current_selected_enemy.name)
	battleState = BATTLE_STATE.ATTACK_SELECT
	await enemy_selected
	current_unit.attack_unit(current_selected_enemy)
	player_units.erase(current_unit)
	insert_sort(player_units, current_unit, 5)
	turnManager.turn = TurnManager.DETERMINE_TURN


func _determine_next_turn():
	print(player_units)
	print(enemy_units)


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
