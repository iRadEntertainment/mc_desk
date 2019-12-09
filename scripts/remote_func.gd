extends Node

signal server_log_received
signal server_log_updated

signal file_content_received
signal existing_users_received


remote func receive_server_log(server_log):
	emit_signal("server_log_received",server_log)

remote func receive_last_server_entry(entry):
	emit_signal("server_log_updated",entry)

remote func return_user_name():
	return glb.user_name

remote func receive_file_content(content):
	emit_signal("file_content_received",content)

remote func receive_existing_users(users):
	emit_signal("existing_users_received",users)
