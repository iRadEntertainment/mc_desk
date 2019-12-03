#=======================#
#    login_panel.gd     #
#=======================#

extends Control

const tag = "Login panel"

onready var tool_sheet = load("res://sprites/login_tools.png")
onready var mats_sheet = load("res://sprites/login_mats.png")

onready var icon_color       = glb.color_pal[0]
onready var icon_hover_color = glb.color_pal[1]
onready var icon_press_color = glb.color_pal[2]

signal update_icon_color

export var code_lenght = 6
export var n_of_tools  = 3
var        code        = []
var        code_step   = 0
var        fl_new_user = false
export var new_pass_confirmation_steps = 3
var        confirmation_step = 0

func _ready():
	#--- signals
	connect_username_buttons()
	connect_grid_buttons_to_self()
	glb.connect("palette_changed",self,"_color_palette_changed")
	glb.connect("server_auth_updated",self,"login_completed")
	#--- setup
	populate_login_grid(0)
	populate_output_grid()
	reset_output_grid()
	
	username_initial_input_state()


#============================== Username Input ==============================
func username_initial_input_state():
	for button in $pnl_pass/vbox/log_btn.get_children():
		button.hide()
#	$pnl_pass/vbox/infos.modulate = Color.transparent
	$pnl_pass/vbox/infos.hide()
	$pnl_pass/vbox/login_icons.hide()
	$pnl_pass/vbox/login_outputs.hide()
	
	
	if glb.user_name != null:
		$pnl_pass/vbox/user_input.text = glb.user_name
	else:
		$pnl_pass/vbox/user_input.text = ""
	$pnl_pass/vbox/user_input.editable = true
	reset_output_grid()

func connect_username_buttons():
	$pnl_pass/vbox/log_btn/log_in.connect("pressed",self,"_log_in_pressed")
	$pnl_pass/vbox/log_btn/new_user.connect("pressed",self,"_new_user_pressed")
	$pnl_pass/vbox/log_btn/switch_user.connect("pressed",self,"_switch_user_pressed")
	
	$pnl_pass/vbox/user_input.connect("text_entered",self,"_username_entered")

func _log_in_pressed():
	for button in $pnl_pass/vbox/log_btn.get_children():
		button.hide()
	$pnl_pass/vbox/log_btn/switch_user.show()
	$pnl_pass/vbox/infos.hide()
	$pnl_pass/vbox/login_icons.show()
	$pnl_pass/vbox/login_outputs.show()
	
	$pnl_pass/vbox/user_input.editable = false

func _new_user_pressed():
	if not netwrk._get_established():
		$pnl_pass/vbox/infos.show()
		$pnl_pass/vbox/infos.text = "No connection to server\nImpossible to create a new user!"
		return
	for button in $pnl_pass/vbox/log_btn.get_children():
		button.hide()
	$pnl_pass/vbox/log_btn/switch_user.show()
	$pnl_pass/vbox/infos.show()
	$pnl_pass/vbox/infos.text = "Choose your password: %s tools and %s materials\nRemember it!"%[n_of_tools,(code_lenght-n_of_tools)]
	$pnl_pass/vbox/login_icons.show()
	$pnl_pass/vbox/login_outputs.show()
	
	glb.user_name = $pnl_pass/vbox/user_input.text
	$pnl_pass/vbox/user_input.editable = false
	fl_new_user = true

func _switch_user_pressed():
	username_initial_input_state()

func _username_entered(val):
	if   $pnl_pass/vbox/log_btn/log_in.visible:
		$pnl_pass/vbox/log_btn/log_in.grab_focus()
	elif $pnl_pass/vbox/log_btn/new_user.visible:
		$pnl_pass/vbox/log_btn/new_user.grab_focus()

#============================== Password Input ==============================

func populate_output_grid():
	var output_inst = $pnl_pass/vbox/login_outputs.get_child(0).duplicate(DUPLICATE_USE_INSTANCING)
	for square in $pnl_pass/vbox/login_outputs.get_children():
		square.queue_free()
	for i in range(code_lenght):
		$pnl_pass/vbox/login_outputs.add_child(output_inst)
		output_inst = output_inst.duplicate()

func connect_grid_buttons_to_self():
	for i in range (16):
		var square = $pnl_pass/vbox/login_icons.get_child(i)
		
		square.connect("pressed",self,"_login_input_button_pressed",[i])

func populate_login_grid(step):
	var sprite_sheet
	#populate with tools or materials
	if step < n_of_tools: sprite_sheet = tool_sheet
	else:                 sprite_sheet = mats_sheet
	
	for i in range (16):
		var square = $pnl_pass/vbox/login_icons.get_child(i)
		
		#---set icons
		for child in square.get_children():
			child.free()
		
		var icon = Sprite.new()
		icon.texture = sprite_sheet
		icon.vframes = 4
		icon.hframes = 4
		icon.frame = i
		icon.modulate = icon_color
		icon.position = square.rect_size/2
		square.add_child(icon)
		square.connect("mouse_entered",icon,"set",["modulate",icon_hover_color])
		square.connect("mouse_exited",icon,"set",["modulate",icon_color])
		square.connect("button_down",icon,"set",["modulate",icon_press_color])
		square.connect("button_up",icon,"set",["modulate",icon_hover_color])
		connect("update_icon_color",icon,"set")
		
		#--- set numbers
		if false: #temporarily disabled
			var num = Label.new()
			num.theme = load("res://styles/small_labels.tres")
			num.text  = str(i+1)
			num.modulate = Color(1,1,1,0.5)
			square.add_child(num)
			num.anchor_right  = 1
			num.anchor_bottom = 1
			num.align  = Label.ALIGN_CENTER
			num.valign = Label.VALIGN_CENTER
			
			num.margin_bottom = 0
			num.margin_top    = 0
			num.margin_left   = 0
			num.margin_right  = 0


func reset_output_grid():
	for child in $pnl_pass/vbox/login_outputs.get_children():
		child.disabled = true
		child.focus_mode = FOCUS_NONE
		for icon in child.get_children():
			icon.free()
	code_step = 0

func _login_input_button_pressed(id):
	if code_step == 0:
		reset_output_grid()
	code.append(id)
	$pnl_pass/col_test.color = code_to_color(code)
	$pnl_pass/col_test/hexadec.text = "#"+code_to_color(code)
	
	#--- add icons to output grid
	var square = $pnl_pass/vbox/login_outputs.get_child(code_step)
	for child in square.get_children():
			child.free()
	var icon = Sprite.new()
	if code_step <n_of_tools: icon.texture = tool_sheet
	else                    : icon.texture = mats_sheet
	icon.vframes = 4
	icon.hframes = 4
	icon.frame   = id
	icon.modulate = icon_color
	icon.position = square.rect_size/2
	square.add_child(icon)
	
	#--- check which grid to show next tools/materials
	code_step += 1
	if code_step >= code_lenght:
		code_step = 0
		code = []
		password_completed(code)
	populate_login_grid(code_step)

func code_to_color(code_array):
	var _color = ""
	for i in range (code.size()):
		var val = code_array[i]
		if val<10:
			val = str(val)
		else:
			match val:
				10: val = "a"
				11: val = "b"
				12: val = "c"
				13: val = "d"
				14: val = "e"
				15: val = "f"
		
		_color += val
	for i in range(code.size(),6):
		_color += "0"
	return _color

func password_completed(code):
	var temp_username = $pnl_pass/vbox/user_input.text
	#--- if server connected
	if netwrk._get_established():
		if fl_new_user:
			confirmation_step += 1
			if confirmation_step < new_pass_confirmation_steps:
				$pnl_pass/vbox/infos.show()
				var message = "Retype your password %s more time to remember it!"%(new_pass_confirmation_steps-confirmation_step)
				$pnl_pass/vbox/infos.text = message
			else:
				fl_new_user = false
				$pnl_pass/vbox/infos.hide()
				confirmation_step = 0
				glb.user_name = temp_username
				remote_func.rpc_id(1, "add_user", glb.user_name , code)
				glb.last_auth = [glb.user_name,code]
				data_mng.save_data(["config"])
		else:
			var login_result = remote_func.rpc_id(1, "auth_request", glb.user_name , code)
			
	#--- if offline
	else:
		pass

func _color_palette_changed(val):
	icon_color       = glb.color_pal[0]
	icon_hover_color = glb.color_pal[1]
	icon_press_color = glb.color_pal[2]
	emit_signal("update_icon_color", "modulate" , icon_color)

func login_completed(success):
	if success:
		glb.emit_signal("login_successful")
		$pnl_pass/vbox/infos.show()
		$pnl_pass/vbox/infos.text = "Welcome %s!"%glb.user_name
		login_succeded_animation()
	else:
		$pnl_pass/vbox/infos.show()
		$pnl_pass/vbox/infos.text = "Login failed! Try again?"
		login_succeded_animation()

func login_succeded_animation():
	#TODO animation for succession
	if glb.server_auth:
		print("Login successful")
