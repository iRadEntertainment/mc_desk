extends LineEdit

func _ready():
	connect("text_changed",self,"_check_for_existing_users")
	connect("text_entered",self,"_text_entered")

func _check_for_existing_users(txt):
	if glb.existing_users:
		$"../log_btn/log_in".visible   =  ( txt in glb.existing_users )
		$"../log_btn/new_user".visible = !( txt in glb.existing_users )
	else:
		$"../log_btn/new_user".visible = true

func _text_entered(val):
	pass

