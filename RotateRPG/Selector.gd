extends Sprite2D

var current_option : set = _set_option, get = _get_option

func _set_option(option):
	current_option = option
	global_position = current_option.global_position
	
func _get_option():
	return current_option
