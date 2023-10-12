extends Node2D

var player_
var currentBattleGround

func move_towards(target_pos):
	var tween  = create_tween()
	tween.tween_property(self, "position", target_pos, 1)


