extends PanelContainer

func _ready():
	connect_all_signals()
	edit_mode(false)


func connect_all_signals():
	$hbox/edit.connect("pressed",self,"edit_mode",[true])
	$hbox/cancel.connect("pressed",self,"edit_mode",[false])


func edit_mode(val):
	lines_edit_editable(val)
	$hbox/edit.visible = !val
	$hbox/save.visible = val
	$hbox/cancel.visible = val
	$hbox/delete.visible = val


func lines_edit_editable(val):
	for child in $hbox.get_children():
		if child is LineEdit:
			child.editable = val