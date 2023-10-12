extends Node2D

var currentUnit = null : set = set_current_unit, get = get_current_unit

func set_current_unit(unit):
	currentUnit = unit
	set_current_unit_position()
	
func get_current_unit():
	return currentUnit

func set_current_unit_position():
	currentUnit.position = global_position
