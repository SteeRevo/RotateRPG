extends Node2D

var turnManager = preload("res://TurnManager.tres")

enum BATTLE_STATE {BASE, ATTACK_SELECT, SKILL_MENU, SKILL_SELECT, ROTATE_SELECT, IN_ATTACK, IN_SKILL, IN_ROTATE}


func _ready():
	$BattleGroundSet/BattleGround.set_current_unit($Player)
	$BattleGroundSet/BattleGround2.set_current_unit($Player2)
	$BattleGroundSet2/BattleGround.set_current_unit($Enemy)
	
	turnManager.connect("player_turn_started", self._on_player_turn_started)
	turnManager.connect("enemy_turn_started", self._on_enemy_turn_started)

func _on_player_turn_started():
	print("player turn")
	
func _on_enemy_turn_started():
	print("enemy turn")


func _on_attack_pressed():
	turnManager.turn = TurnManager.ENEMY_TURN


func _on_rotate_pressed():
	$Player.move_towards($BattleGroundSet/BattleGround2.global_position)
	$Player2.move_towards($BattleGroundSet/BattleGround.global_position)
