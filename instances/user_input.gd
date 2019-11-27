extends LineEdit

var existing_users

func _ready():
	yield(netwrk,"network_status_changed")
	if netwrk._get_established():
		connect("text_changed",self,"_check_for_existing_users")
		connect("text_entered",self,"_text_entered")
		existing_users = remote_func.rpc_id(1,"send_existing_users")

func _check_for_existing_users(txt):
	if existing_users:
		$"../log_btn/log_in".visible   =  ( txt in existing_users )
		$"../log_btn/new_user".visible = !( txt in existing_users )
	else:
		$"../log_btn/new_user".visible = true

func _text_entered(val):
	var ciccio = remote_func.rpc_id(1,"send_existing_users")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	print(ciccio)
