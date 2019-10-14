#====================#
#      MAIN.GD       #
#====================#

extends Control






func _ready():
	netwrk.connect_to_server()


func popup_notification(content = null, title = null, duration = 2):
	var popup_notif = load("res://instances/notification.tscn").instance()
	popup_notif.title    = title
	popup_notif.content  = content
	popup_notif.duration = float(duration)
	add_child(popup_notif)

func show_panel(panel_name):
	for child in $vbox/cnt_center.get_children():
		child.hide()
	match panel_name:
		"control panel" : glb.pnl_control_room.show()
		"login panel"   : glb.pnl_login.show()
		"finance panel" : glb.pnl_finance.show()
		"tasks panel"   : glb.pnl_tasks.show()