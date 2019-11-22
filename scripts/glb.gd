#===================#
#     GLOBAL.GD     #
#===================#

extends Node

#user
var user_name    = null

#log
var log_max_size = 1000

#swipe_detect
var fl_screen_p = false
var fl_dragging = false
var current_tab = 1

#nodes
onready var main             = $"/root/main"
#onready var pnl_control_room = $"/root/main/vbox/cnt_center/control_room"
#onready var pnl_login        = $"/root/main/vbox/cnt_center/login_panel"
#onready var pnl_finance      = $"/root/main/vbox/cnt_center/finance_panel"
#onready var pnl_tasks        = $"/root/main/vbox/cnt_center/tasks_panel"
var pnl_control_room = preload("res://instances/control_room.tscn").instance()
var pnl_login        = preload("res://instances/login_panel.tscn").instance()
var pnl_finance      = preload("res://instances/finance_panel.tscn").instance()
var pnl_tasks        = preload("res://instances/tasks_panel.tscn").instance()
var pnl_settings     = preload("res://instances/settings.tscn").instance()

onready var permission_all = [pnl_control_room,pnl_login,pnl_finance,pnl_tasks,pnl_settings]
#colors
signal palette_changed
const col_red    = Color("D2222D")
const col_green  = Color("007000")
const col_yellow = Color("FFBF00")
var color_pal = ["010010","63185d","fff641","b9c7ec","5e8254"] setget _palette_changed

#--------------------- console utilities ---------------------
func log_print(string):
	var unix = OS.get_unix_time()
	var log_entry = [unix,string]
	var console_log = data_mng.console_log
	console_log.push_back(log_entry)
	while console_log.size() > log_max_size:
		console_log.pop_front()
	
	print(format_log_entry(log_entry))
	data_mng.console_log = console_log

func format_log_entry(log_entry):
	var unix = log_entry[0]
	var dic = OS.get_datetime_from_unix_time(unix)
	var time = [dic["month"],dic["day"],dic["hour"],dic["minute"],dic["second"]]
	var string = log_entry[1]
	#print sdtout
	var time_str   = "%02d/%02d [%02d:%02d:%02d]"%time
	var format_str = "%s - %s"%[time_str,string]
	return (format_str)

#--------------------- other utilities ---------------------

#--------------------- Color palette  ---------------------
func _palette_changed(val):
	if !typeof(val) == TYPE_ARRAY:
		print("Color palette updated incorrectly, Type != Array")
		return
	if val.size() != 5:
		print("Color palette array != 5")
		return
	print("GLB: palette_changed")
	color_pal = val
	emit_signal("palette_changed",val)
















