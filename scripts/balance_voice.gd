extends PanelContainer





func _ready():
	connect_all_signals()
	edit_mode(false)
	$odd_overlay.visible = get_index()%2 == 1
	yield(get_tree(),"idle_frame")
	deletable( get_parent().get_child_count() - 2 == get_index() )


func connect_all_signals():
	#--- EDIT mode
	$hbox/edit.connect("pressed",self,"edit_mode",[true])
	$hbox/cancel.connect("pressed",self,"edit_mode",[false])
	
	$hbox/delete.connect("pressed",self,"delete")


func edit_mode(val):
	lines_edit_editable(val)
	$hbox/edit.visible = !val
	$hbox/save.visible = val
	$hbox/cancel.visible = val
#	$hbox/delete.visible = val

func delete():
	queue_free()

func lines_edit_editable(val):
	for child in $hbox.get_children():
		if child is LineEdit:
			child.editable = val
		if child is OptionButton:
			child.disabled = !val
	
	if val: set("custom_styles/panel", load("res://styles/finance_list_edit.tres"))
	else:   set("custom_styles/panel", load("res://styles/finance_list_normal.tres"))

func deletable(val):
	$hbox/delete.visible = val
