tool
extends TextureButton

###########################
# README
# How to use CalendarButton: 
# 
# In order to get the data from CalendarButton, we must create a connection.
# Example of use from your script:
# -----------------------------------
#
# var calendar_button_node = get_node("path/to/CalendarButton")
# calendar_button_node.connect("date_selected", self, "your_func_here")
#
# func your_func_here(date_obj):
# 	print(date_obj.date())
#
# -----------------------------------
# Whenever you select a day using CalendarButton, 
# a Date object will be sent to your script. 
# 
# Read res://addons/calendar_button/class/Date.gd for more info on Date object
###########################

# Stored date object
var date

# Signal to notify when a button has been clicked
signal date_selected(date_obj)

# Path
var month_year_path = "PanelContainer/vbox/hbox_month_year/"
var btn_img_path = "res://addons/calendar_button/btn_img/"

# Classes
onready var Calendar = load("res://addons/calendar_button/class/Calendar.gd").new()
var Date = preload("res://addons/calendar_button/class/Date.gd")

# Nodes
var popup = null
var label_month_year_node = null
var month_days_node = null

# Saved time selection
var selected_month
var selected_year
var selected_day

# Runs when added to editor / tree
func _enter_tree():
	setup_calendar_button()
	
	# Setup popup and connections
	popup = preload("res://addons/calendar_button/popup.tscn").instance()
	popup.get_node(month_year_path + "button_prev_month").connect("pressed",self,"go_prev_month")
	popup.get_node(month_year_path + "button_next_month").connect("pressed",self,"go_next_month")
	popup.get_node(month_year_path + "button_prev_year").connect("pressed",self,"go_prev_year")
	popup.get_node(month_year_path + "button_next_year").connect("pressed",self,"go_next_year")
	
	# Get nodes
	label_month_year_node = popup.get_node(month_year_path + "label_month_year")
	month_days_node = popup.get_node("PanelContainer/vbox/hbox_days")
	
	# Add signal to all buttons, which returns button node
	for i in range(42):
		var btn_node = month_days_node.get_node("btn_" + str(i))
		btn_node.connect("pressed", self, "day_pressed", [btn_node]) # will send name of button
	
	Calendar = load("res://addons/calendar_button/class/Calendar.gd").new()
	load_data()


# Runs when user presses a day button
func day_pressed(btn_node):
	# Close popup
	close_popup()
	
	# Update selected day
	selected_day = int(btn_node.get_text())
	
	# Store Date
	date = Date.new(selected_day, selected_month, selected_year)
	
	# Send signal with Date object to whomever needs it
	emit_signal("date_selected", date)


# A one time setup of the Calendar button
func setup_calendar_button():
	# Button settings
	set_toggle_mode(true)
	
	# Set "Normal" Button Texture
	var image_normal = Image.new()
	image_normal.load(btn_img_path + "btn_32x32_03.png")
	var image_texture_normal = ImageTexture.new()
	image_texture_normal.create_from_image(image_normal)
	set_normal_texture(image_texture_normal)

	# Set "Pressed" Button Texture
	var image_pressed = Image.new()
	image_pressed.load(btn_img_path + "btn_32x32_04.png")
	var image_texture_pressed = ImageTexture.new()
	image_texture_pressed.create_from_image(image_pressed)
	set_pressed_texture(image_texture_pressed)


# Load data on _init
func load_data():
	# Load todays date by default
	selected_month = Calendar.month()
	selected_year = Calendar.year()
	selected_day = Calendar.day()
	
	# Refresh popup with current data
	refresh_data()


# Reloads popup data
func refresh_data():
	# Update label with current month and year
	label_month_year_node.set_text(str(Calendar.get_month_name(selected_month)) + " " + str(selected_year))
	
	# Clear all nodes
	for i in range(42):
		var btn_node = month_days_node.get_node("btn_" + str(i))
		btn_node.set_text("")
		btn_node.set_disabled(true)
	
	# Get the week day for the first day in this month of this year
	var week_day = Calendar.get_weekday(1, selected_month, selected_year)
	
	# This months number of days
	var current_month_num_days = Calendar.get_number_of_days(selected_month, selected_year)
	
	# Draw the days for this month belonging to the correct weekday
	for i in range(current_month_num_days):
		var btn_node = month_days_node.get_node("btn_" + str(i + week_day))
		btn_node.set_text(str(i+1))
		btn_node.set_disabled(false)
		
		# If the day entered is "today"
		if(i+1 == Calendar.day() && selected_year == Calendar.year() && selected_month == Calendar.month() ):
			# Make it obvious that this is today
			btn_node.set_flat(true)
		else:
			btn_node.set_flat(false)
			pass


# Makes sure the popup window does not leave the screen
func check_position():
	var cal = popup.get_parent()
	var popup_container = popup.get_node("PanelContainer")
	
	var difference_x = 0
	var difference_y = 0
	
	
	var x_total = cal.rect_position.x + cal.get_size().x + popup_container.rect_position.x + popup_container.get_size().x
	if(x_total > OS.get_window_size().x):
		difference_x = x_total - OS.get_window_size().x
	
	var y_total = cal.rect_position.y + cal.get_size().y + popup_container.rect_position.y + popup_container.get_size().y
	if(y_total > OS.get_window_size().y):
		difference_y = y_total - OS.get_window_size().y
	
	popup_container.rect_position =Vector2(popup_container.rect_position.x - difference_x, popup_container.rect_position.y - difference_y)


func go_prev_month():
	# Decrease by one
	selected_month -= 1
	
	# If we have less than 1, set to december (12) and decrease year by one
	if(selected_month < 1):
		selected_month = 12
		selected_year -= 1
	
	# Refresh data
	refresh_data()


func go_next_month():
	# Increment by one
	selected_month += 1
	
	# If we have surpassed 12, set to january (1) and increase year by one
	if(selected_month > 12):
		selected_month = 1
		selected_year += 1
	
	# Refresh data
	refresh_data()


func go_prev_year():
	# Decrease year by one
	selected_year -= 1
	
	# Refresh data
	refresh_data()


func go_next_year():
	# Increase year by one
	selected_year += 1
	
	# Refresh data
	refresh_data()


func close_popup():
	popup.hide()
	# check_outside_press.hide()
	set_pressed(false)


func toggled(is_pressed):
	if(!is_pressed):
		close_popup()
	else:
		if(has_node("popup")):
			popup.show()
		else:
			add_child(popup)
	
	# If the button is placed close to a corner; we make sure we can see the entire popup
	check_position()
