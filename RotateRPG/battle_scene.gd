extends Node2D

var turnManager = preload("res://TurnManager.tres")

#battlestates
enum BATTLE_STATE {BASE, ATTACK_SELECT, SKILL_MENU, SKILL_SELECT, ROTATE_SELECT, ROTATE_COMMIT, IN_ATTACK, IN_SKILL, IN_ROTATE, ATTACK_COMMIT}

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

var current_selected_ally_bg

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
signal attack_anim_finished
signal ally_bg_selected

var turn_count = 0



func _ready():
	
	set_starting_BG_unit_position($PlayerUnits/Sanazaki)
	set_starting_BG_unit_position($PlayerUnits/Leo)
	set_starting_BG_unit_position($PlayerUnits/Punk)
	set_starting_BG_unit_position($EnemyUnits/Enemy)
	set_starting_BG_unit_position($EnemyUnits/Enemy2)

	
	
	$PlayerUnits/Sanazaki.set_idle()
	
	playerBGFront.set_current_unit_position()
	playerBGTopWing.set_current_unit_position()
	playerBGBotWing.set_current_unit_position()
	enemyBGFront.set_current_unit_position()
	enemyBGTopWing.set_current_unit_position()
	
	current_selected_enemy = $EnemyUnits/Enemy
	
	
	battleState = BATTLE_STATE.BASE
	
	get_all_units()
	#calc turn advance
	set_current_unit()
	
	
	
	
	turnManager.connect("player_turn_started", self._on_player_turn_started)
	turnManager.connect("enemy_turn_started", self._on_enemy_turn_started)
	turnManager.connect("determine_next_turn", self._determine_next_turn)
	
	turnManager.turn = TurnManager.PLAYER_TURN


func insert_sort(lst, unit, action_weight):
	unit.calc_turn_order(action_weight)
	for i in range(len(lst)):
		if lst[i]._get_turn_order() > unit._get_turn_order():
			lst.insert(i, unit)
			return lst
	lst.append(unit)
	return lst

func get_all_units():
	for unit in $PlayerUnits.get_children():
		insert_sort(player_units, unit, 100)
		unit_list.append(unit)
	for unit in $EnemyUnits.get_children():
		insert_sort(enemy_units, unit, 100)
		unit_list.append(unit)

	
	
	print_current_status()
	
func set_current_unit():
	if player_units[0]._get_turn_order() <= enemy_units[0]._get_turn_order():
		current_unit = player_units[0]
		calc_turn_advance()
		turnManager.turn = TurnManager.PLAYER_TURN
	else:
		current_unit = enemy_units[0]
		calc_turn_advance()
		turnManager.turn = TurnManager.ENEMY_TURN
		
	
	
		
func _determine_next_turn():
	
	turn_count += 1
	set_current_unit()
	

func calc_turn_advance():
	var turn_advance = current_unit._get_turn_order()
	current_unit._set_turn_order(0)
	for unit in player_units:
		unit._set_turn_order(unit._get_turn_order() - turn_advance)
	for unit in enemy_units:
		unit._set_turn_order(unit._get_turn_order() - turn_advance)
		
	
func _input(event):
	if event.is_action_pressed("Attack") and battleState == BATTLE_STATE.BASE and turnManager.turn == TurnManager.PLAYER_TURN:
		_on_attack_pressed()
		
	elif event.is_action_pressed("Rotate") and battleState == BATTLE_STATE.BASE and turnManager.turn == TurnManager.PLAYER_TURN:
		_on_rotate_pressed()
	# -------------------------------------------- ROTATE SELECT ------------------------------------------------------------------------
		
	elif (battleState == BATTLE_STATE.ROTATE_SELECT or battleState == BATTLE_STATE.ROTATE_COMMIT) and turnManager.turn == TurnManager.PLAYER_TURN:
		rotate_input_reader(event)
		
	# --------------------------------------- ATTACK SELECT -----------------------------------------------------------------------------
	elif (battleState == BATTLE_STATE.ATTACK_SELECT or battleState == BATTLE_STATE.ATTACK_COMMIT) and turnManager.turn == turnManager.PLAYER_TURN:
		attack_input_reader(event)
	
	
		

		
func rotate_input_reader(event):
	if event.is_action_pressed("Rotate") and battleState == BATTLE_STATE.ROTATE_COMMIT:
		battleState = BATTLE_STATE.ROTATE_SELECT
		print("Current selected ally: " + current_selected_ally_bg._get_current_unit().name)
	
	elif event.is_action_pressed("Attack") and battleState == BATTLE_STATE.ROTATE_COMMIT:
		ally_bg_selected.emit()
	
	elif event.is_action_pressed("Attack"):
		set_current_selected_ally_bg(playerBGFront)
		
	elif event.is_action_pressed("Skill"):
		set_current_selected_ally_bg(playerBGTopWing)
	
	elif event.is_action_pressed("Item"):
		set_current_selected_ally_bg(playerBGBotWing)
		
	elif event.is_action_pressed("Rotate"):
		set_current_selected_ally_bg(playerBGBack)
		
func attack_input_reader(event):
	if event.is_action_pressed("Attack") and battleState == BATTLE_STATE.ATTACK_COMMIT:
		enemy_selected.emit()
		
	elif event.is_action_pressed("Rotate") and battleState == BATTLE_STATE.ATTACK_COMMIT:
		battleState = BATTLE_STATE.ATTACK_SELECT
		print("Current selected enemy: " + current_selected_enemy.name)
		
	elif event.is_action_pressed("Attack"):
		set_current_selected_enemy(enemyBGBack._get_current_unit())
		
	elif event.is_action_pressed("Skill"):
		set_current_selected_enemy(enemyBGTopWing._get_current_unit())
		
	elif event.is_action_pressed("Item"):
		set_current_selected_enemy(enemyBGBotWing._get_current_unit())
		
	elif event.is_action_pressed("Rotate"):
		set_current_selected_enemy(enemyBGFront._get_current_unit())
		
	

	
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

func set_current_selected_ally_bg(ally):
	if ally != null:
		current_selected_ally_bg = ally
	else:
		print("No Enemy Here")
	if current_selected_ally_bg._get_current_unit() != null:
		print("Current selected Ally: " + current_selected_ally_bg._get_current_unit().name)
	print("A to back out, D to commit")
	battleState = BATTLE_STATE.ROTATE_COMMIT
	

	
	
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
	for unit in player_units:
		print(unit.name + ": current turn_order = " + str(unit._get_turn_order()))
	for unit in enemy_units:
		print(unit.name + ": current turn_order = " + str(unit._get_turn_order()))
	print("Current Unit is: " + current_unit.name)
	print("Press D to attack, A to rotate, W for Skill, S for item.")
	battleState = BATTLE_STATE.BASE
	


func _on_enemy_turn_started():
	print("========enemy turn=========")
	for unit in player_units:
		print(unit.name + ": current turn_order = " + str(unit._get_turn_order()))
	for unit in enemy_units:
		print(unit.name + ": current turn_order = " + str(unit._get_turn_order()))
	current_unit.attack_unit(player_units[0])
	enemy_units.erase(current_unit)
	insert_sort(enemy_units, current_unit, 40)
	turnManager.turn = TurnManager.DETERMINE_TURN


func _on_attack_pressed():
	print("Player selects unit to attack")
	for unit in enemy_units:
		print(unit.name)
	
	print("Current selected enemy: " + current_selected_enemy.name)
	battleState = BATTLE_STATE.ATTACK_SELECT
	await enemy_selected
	#current_unit.play_attack()
	#await attack_anim_finished
	#current_unit.set_idle()
	current_unit.attack_unit(current_selected_enemy)
	player_units.erase(current_unit)
	insert_sort(player_units, current_unit, 40)
	turnManager.turn = TurnManager.DETERMINE_TURN




func _on_rotate_pressed():
	print("Player selects ally to rotate")
	for unit in player_units:
		if current_unit.name != unit.name:
			print(unit.name)
	battleState = BATTLE_STATE.ROTATE_SELECT
	await ally_bg_selected
	rotate_units(current_unit, current_selected_ally_bg._get_current_unit(), current_unit._get_BG(), current_selected_ally_bg)
	player_units.erase(current_unit)
	insert_sort(player_units, current_unit, 30)
	turnManager.turn = TurnManager.DETERMINE_TURN

func rotate_units(unit1, unit2, bg1, bg2):
	unit1.move_towards(bg2.global_position)
	set_BG_unit_position(unit1, bg2)
	if(unit2 != null):
		unit2.move_towards(bg1.global_position)
	set_BG_unit_position(unit2, bg1)
	
func set_starting_BG_unit_position(unit):
	var bg
	if unit != null :
		if unit.startingBG == unit.battleGrounds.PF:
			bg = $BattleGroundSet/BattleGround
		elif unit.startingBG == unit.battleGrounds.PTW:
			bg = $BattleGroundSet/BattleGround2
		elif unit.startingBG == unit.battleGrounds.PBW:
			bg = $BattleGroundSet/BattleGround3
		elif unit.startingBG == unit.battleGrounds.PB:
			bg = $BattleGroundSet/BattleGround4
		elif unit.startingBG == unit.battleGrounds.EF:
			bg = $BattleGroundSet2/BattleGround1
		elif unit.startingBG == unit.battleGrounds.ETW:
			bg = $BattleGroundSet2/BattleGround2
		elif unit.startingBG == unit.battleGrounds.EBW:
			bg = $BattleGroundSet2/BattleGround3
		elif unit.startingBG == unit.battleGrounds.EB:
			bg = $BattleGroundSet2/BattleGround4
		
	unit._set_BG(bg)
	bg._set_current_unit(unit)
	
func set_BG_unit_position(unit, bg):
	if unit != null:
		unit._set_BG(bg)
	bg._set_current_unit(unit)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Attack":
		attack_anim_finished.emit()
