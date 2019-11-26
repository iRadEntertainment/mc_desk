#====================#
#      MAIN.GD       #
#====================#

extends Control

signal new_popup

var tab_button_preload = preload("res://instances/tab_button.tscn")



func _ready():
	populate_central_panel()#("login")
	netwrk.test_internet_connectivity()
	netwrk.connect_to_server()
	glb.connect("palette_changed",self,"_color_palette_changed")
	return
	populate_central_panel()
	apply_color_palette()


func popup_notification(content = null, title = null, duration = 2):
	emit_signal("new_popup")
	var popup_notif = load("res://instances/notification.tscn").instance()
	popup_notif.title    = title
	popup_notif.content  = content
	popup_notif.duration = float(duration)
	add_child(popup_notif)
	connect("new_popup",popup_notif,"queue_free")

#------------------------ panels ---------------------------

func show_panel(tag):
	for child in $vbox/cnt_center.get_children():
		child.hide()
		if tag == child.name:
			child.show()
	

func populate_central_panel(permission = null):
	print("MAIN: populating central area")
	for panel in $vbox/cnt_center.get_children():
		panel.queue_free()
	for tab_button in $vbox/top_bar/hbox/tabs_buttons.get_children():
		tab_button.queue_free()
	
	if permission == null:
		permission = "all"
	match permission:
		"all":
			for panel in glb.permission_all:
				add_panel_to_central_container(panel)
				show_panel("none")
		"login":
			add_panel_to_central_container(glb.pnl_login)
			add_panel_to_central_container(glb.pnl_settings)
			show_panel("login_panel")
	
	$vbox/top_bar/hbox/tabs_buttons.hide()
	yield(get_tree(),"idle_frame")
	$vbox/top_bar/hbox/tabs_buttons.show()


func add_panel_to_central_container(instance):
	$vbox/cnt_center.add_child(instance)
	
	var tab_button_instance = tab_button_preload.instance()
	tab_button_instance.name = instance.name+"_tab"
	tab_button_instance.tag = instance.name
	if instance.get("tag"):
		tab_button_instance.text = instance.tag
	else:
		tab_button_instance.text = instance.name
	$vbox/top_bar/hbox/tabs_buttons.add_child(tab_button_instance)
	tab_button_instance.hide()
	tab_button_instance.show()

#----------------------- colors ---------------------------
func apply_color_palette(val = null):
	if !val: val = glb.color_pal
	$bg.color = Color(glb.color_pal[2])
	$vbox/top_bar/bg.color = Color(glb.color_pal[3])
	$vbox/bot_bar/bg.color = Color(glb.color_pal[3])
	for child in $vbox/top_bar/hbox.get_children() + $vbox/bot_bar/hbox.get_children():
		if child is Label:
			child.add_color_override("font_color", Color(glb.color_pal[1]))
		if child is TextureRect and child.name != "wifi_ico":
			child.modulate = Color(glb.color_pal[0])
	
	for node in get_tree().get_nodes_in_group("theme_nodes"):
		node.add_color_override("font_color", Color(glb.color_pal[1]))
	
	get_tree().call_group("theme_nodes", "theme_update")
	get_tree().call_group("theme_nodes", "update")

func _color_palette_changed(val):
	apply_color_palette(val)

func _updates_themes_with_new_color_palette(val):
	#TODO update themes with the new color palette
	var styl_button_normal = theme.get_stylebox("Normal","Button")
	styl_button_normal.set("bg_color",glb.color_pal[2])
	theme.set_stylebox("Normal","Button",styl_button_normal)
	
	
	
	
