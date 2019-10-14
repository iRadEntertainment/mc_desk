extends CenterContainer

var title   : String
var content : String

var duration : float


func _ready():
	if !title and !content:
		queue_free()
	
	$panel.connect("mouse_exited",self,"queue_free")
	
	if !title: $panel/vbox/title.hide()
	else: $panel/vbox/title.text = title
	
	if !content: $panel/vbox/content.hide()
	else: $panel/vbox/content.text = content
	
	if duration:
		$tmr.wait_time = duration
	$tmr.start()
	$tmr.connect("timeout",self,"queue_free")
	
	
