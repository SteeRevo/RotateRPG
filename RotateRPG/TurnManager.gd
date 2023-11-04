extends Resource
class_name TurnManager

enum {PLAYER_TURN, ENEMY_TURN, DETERMINE_TURN}

var turn = null : set = set_turn, get = get_turn

signal player_turn_started
signal enemy_turn_started
signal determine_next_turn

func set_turn(val):
	turn = val
	match turn:
		PLAYER_TURN: emit_signal("player_turn_started")
		ENEMY_TURN: emit_signal("enemy_turn_started")
		DETERMINE_TURN: emit_signal("determine_next_turn")
	
func get_turn():
	return turn
