extends Control

const tag = "KEY_CTRL_ROOM"

func _ready():
	show_panel(2)

func show_panel(pnl = 0):
	$hbox/pnl2.hide()
	$hbox/pnl3.hide()
	match pnl:
		2: $hbox/pnl2.show()
		3: $hbox/pnl3.show()
