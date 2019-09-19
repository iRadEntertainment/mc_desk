#=========================#
#    finance_panel.gd     #
#=========================#

extends Control






func _ready():
	$cal_1.connect("date_selected",self,"date_sel")


func date_sel(date):
	print(date.date())