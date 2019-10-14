#=========================#
#    finance_panel.gd     #
#=========================#

extends Control






func _ready():
	$cal_1.connect("date_selected",self,"date_sel")
	compile_voices_list()


func date_sel(date):
	print(date.date())

func compile_voices_list():
	pass
	add_plus_button()
	

func add_plus_button():
	var button_add = Button.new()
	button_add.theme = load("res://styles/regular_buttons1.tres")
	button_add.icon  = load("res://sprites/btn_piu.png")
	button_add.size_flags_horizontal = SIZE_EXPAND_FILL
	button_add.align = Button.ALIGN_CENTER
	button_add.connect("pressed",self,"_add_new_balance_voice")
	$scrl/voice_list.add_child(button_add)


func _add_new_balance_voice():
	var child_count = $scrl/voice_list.get_child_count()
	
	#--- delete plus button
	$scrl/voice_list.get_child(child_count-1).queue_free()
	
	#--- add new instance
	var new_voice = load("res://instances/balance_voice.tscn").instance()
#	yield(get_tree(),"idle_frame")
	$scrl/voice_list.add_child(new_voice)
	new_voice.deletable(true)
	$scrl/voice_list.get_child(child_count-2)
	
	#--- add plus button back
	add_plus_button()





