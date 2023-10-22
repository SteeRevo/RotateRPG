extends Control


@onready var selector = $Selector
@onready var rotate = $Rotate
@onready var attack = $Attack
@onready var skill = $Skill

# Called when the node enters the scene tree for the first time.
func _ready():
	selector._set_option(rotate)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
