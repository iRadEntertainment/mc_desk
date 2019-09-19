extends Node

signal server_log_received
signal server_log_updated
var server_log

remote func receive_server_log(val):
	server_log = val
	emit_signal("server_log_received",server_log)
	return
	for entry in val:
		var date = entry[0]
		var user = entry[1]
		var msg  = entry[2]
		prints(user,msg)

remote func receive_last_server_entry(entry):
	emit_signal("server_log_updated",entry)

remote func return_user_name():
	return glb.user_name
	