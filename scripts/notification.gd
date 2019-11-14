extends CenterContainer

var title   : String
var content : String

var duration : float


func _ready():
	if !title and !content:
		queue_free()
	
	$panel.connect("mouse_exited",self,"close_popup")
	
	if !title: $panel/vbox/title.hide()
	else: $panel/vbox/title.text = title
	
	if !content: $panel/vbox/content.hide()
	else: $panel/vbox/content.text = content
	
	if duration:
		$tmr.wait_time = duration
	$tmr_min_duration.start()
	$tmr.start()
	$tmr.connect("timeout",self,"queue_free")

func close_popup():
	if $tmr_min_duration.is_stopped():
		queue_free()
