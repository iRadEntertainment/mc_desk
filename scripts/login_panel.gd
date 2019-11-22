#=======================#
#    login_panel.gd     #
#=======================#

extends Control

const tag = "Login panel"

onready var tool_sheet = load("res://sprites/login_tools.png")
onready var mats_sheet = load("res://sprites/login_mats.png")

var icon_color       = Color.blueviolet setget _icon_color_changed
var icon_hover_color = Color.darkorange
var icon_press_color = Color.darkkhaki

signal update_icon_color

export var code_lenght = 4
var        code        = []
var        code_step   = 0

func _ready():
	connect_grid_buttons_to_self()
	populate_login_grid(true)
	populate_output_grid()
	reset_output_grid()


func populate_output_grid():
	var output_inst = $login_outputs.get_child(0).duplicate()
	pass

func connect_grid_buttons_to_self():
	for i in range (16):
		var square = $login_icons.get_child(i)
		
		square.connect("pressed",self,"_login_input_button_pressed",[i])

func populate_login_grid(val):
	var sprite_sheet
	match val: #populate with tools or materials
		true:  sprite_sheet = tool_sheet
		false: sprite_sheet = mats_sheet
	
	
	for i in range (16):
		var square = $login_icons.get_child(i)
		
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
	for child in $login_outputs.get_children():
		child.disabled = true
		child.focus_mode = FOCUS_NONE
		for icon in child.get_children():
			icon.free()

func _login_input_button_pressed(id):
	code.append(id)
	$col_test.color = code_to_color(code)
	$col_test/hexadec.text = "#"+code_to_color(code)
	
	#--- add icons to output grid
	var square = $login_outputs.get_child(code_step)
	for child in square.get_children():
			child.free()
	var icon = Sprite.new()
	if code_step <2: icon.texture = tool_sheet
	else           : icon.texture = mats_sheet
	icon.vframes = 4
	icon.hframes = 4
	icon.frame = id
	icon.modulate = icon_color
	icon.position = square.rect_size/2
	square.add_child(icon)
	
	#--- check which grid to show next tools/materials
	code_step += 1
	populate_login_grid(code_step < 2 or code_step > 5)
	if code_step >= 4:
		code_step = 0
		code = []
#		reset_output_grid()

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

func _icon_color_changed(val):
	icon_color = val
	emit_signal("update_icon_color", "modulate" , icon_color)
