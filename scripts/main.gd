extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	netwrk.connect_to()

func show_panel(panel_name):
	for child in $cnt_center.get_children():
		child.hide()
	match panel_name:
		"control panel": glb.pnl_control_room.show()
		"login panel"  : glb.pnl_login.show()