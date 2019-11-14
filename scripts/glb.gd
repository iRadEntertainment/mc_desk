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
onready var pnl_control_room = $"/root/main/vbox/cnt_center/control_room"
onready var pnl_login        = $"/root/main/vbox/cnt_center/login_panel"
onready var pnl_finance      = $"/root/main/vbox/cnt_center/finance_panel"
onready var pnl_tasks        = $"/root/main/vbox/cnt_center/tasks_panel"

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


