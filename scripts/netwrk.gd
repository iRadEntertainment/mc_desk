#====================#
#     netwrk.gd      #
#====================#
extends Node

var   host        = NetworkedMultiplayerENet.new()
const PORT        = 5000
const ADDRESS     = "81.4.107.146" #"127.0.0.1" #"81.4.107.146"

#timer reconnect
const CONNECTION_ATTEMPTS_STEPS = 5
const TMR_WAIT    = 2 #secondos
const TMR_WAIT_MAX    = 2 #secondos
var   reconnect_timer = Timer.new()
var   connection_attempt = 0

#network
signal network_connected
signal network_status_changed
signal internet_status_changed

var fl_internet_connection = false
var established = false setget _set_established, _get_established
var connecting  = false
var logged_in   = false

#authentication
var net_id      = -1


#============================ INIT ==============================
func _ready():
	#check connectivity
	add_child(http)
	test_internet_connectivity()
	http.connect("request_completed",self,"_HTTP_test_completed")
	#connect network signals
	get_tree().multiplayer.connect("network_peer_packet",self,"_on_packets_received")
	get_tree().connect("connected_to_server",self,"_on_connection_succeeded")
	get_tree().connect("connection_failed",self,"_on_connection_failed")
	
	get_tree().connect("network_peer_connected", self, "_on_user_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_user_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	#create timer for reconnetcion attempts
	set_timer_for_reconnect()
	add_child(reconnect_timer)
	reconnect_timer.connect("timeout",self,"_attempt_reconnection")

func connect_to_server():
	var res = host.create_client(ADDRESS,PORT)
	
	if res != OK:
		glb.log_print ("NETWORK: Impossible to create client")
		return
	else:
		if connection_attempt == 0:
			glb.log_print ("NETWORK: connecting to server...")
		elif connection_attempt%5 == 1:
			glb.log_print( "NETWORK: retrying... attempt n. %02d - wait time %ss"% [connection_attempt , reconnect_timer.wait_time] )
	
	
	get_tree().set_network_peer(null)
	get_tree().set_network_peer(host)
	net_id = get_tree().multiplayer.get_network_unique_id()
	
	#start timer for reconnection attempts
	connecting = true
	reconnect_timer.start()

func disconnect_from_server():
	get_tree().set_network_peer(null)
	host.close_connection()
	self.established = false
	connecting       = false
	reconnect_timer.stop()
	connection_attempt = 0

func _attempt_reconnection(): #on reconnect_timer "timeout"
	connection_attempt += 1
	if connection_attempt%CONNECTION_ATTEMPTS_STEPS == 0 and reconnect_timer.wait_time < 300:
		reconnect_timer.wait_time *= 2
	
	if host.get_connection_status() != NetworkedMultiplayerENet.CONNECTION_DISCONNECTED:
		host.close_connection()
	connect_to_server()

#----------------- network signal functions ---------------------
func _on_connection_failed():
#	$scr/bg/lb_print.text = str($scr/bg/lb_print.text,"\n","Connection failed - ","Error: ")
	get_tree().set_network_peer(null)
	self.established = false
	glb.log_print("NETWORK: connection failed")
	
	if reconnect_timer.is_stopped():
		if not connecting:
			set_timer_for_reconnect()
			connecting = true
		reconnect_timer.start()
	
func _on_connection_succeeded():
#	$scr/bg/lb_print.text = str($scr/bg/lb_print.text,"\n","Connection succeded - ")
	glb.log_print("NETWORK: connection succeeded")
	glb.log_print("NETWORK: my peer ID = %s, server port = %s"%[net_id,host.get_peer_port(1)])
	glb.log_print("NETWORK: server IP  = %s"%host.get_peer_address(1))
	
	self.established   = true
	connecting         = false
	connection_attempt = 0
	reconnect_timer.stop()
	set_timer_for_reconnect()
	emit_signal("network_connected")

#----------------- network communications ---------------------

func _on_packets_received(id,packet):
	#id == 1: id = "Server"
	pass

func _on_user_connected(id):
	if !get_tree().is_network_server(): return
	if id==1: return
	glb.log_print("NETWORK: user connected %s, IP: %s"%[id,host.get_peer_address(id)])

func _on_user_disconnected(id):
	glb.log_print("NETWORK: user disconnected %s"%id)

func _on_server_disconnected():
	glb.log_print("NETWORK: server disconnected")
	self.established = false
	connecting       = true
	set_timer_for_reconnect()
	reconnect_timer.start()

func send_msg_data(dat, id = 0):
	#id == 0: all peers
	var err = get_tree().multiplayer.send_bytes(var2bytes(dat),id)
	if err == OK:
		glb.log_print( "NETWORK: -> %s - %s"%[ id , dat ] )
	else:
		glb.log_print( "NETWORK: unable to send %s - %s\nError: %s"%[ id , dat , err] )




#--------------------- network signals and timer --------------------------

func set_timer_for_reconnect():
	reconnect_timer.wait_time = TMR_WAIT
	reconnect_timer.one_shot = true

func _set_established(val):
	established = val
	emit_signal("network_status_changed",val)

func _get_established():
	if (get_tree().get_network_peer()):
		if get_tree().get_network_peer().get_connection_status() == 2:
			if !established: established = true
		else:
			if  established: established = false
	else:
		if  established: established = false
	return established

#------------------- check internet connection --------------------------

var http = HTTPRequest.new()
func test_internet_connectivity():
	http.cancel_request()
	http.request("https://example.com")
	print("Testing Internet connection. Previou status: %s"%fl_internet_connection)
	fl_internet_connection = false
	emit_signal("internet_status_changed",fl_internet_connection)

func _HTTP_test_completed( result, response_code, headers, body):
	fl_internet_connection = result == HTTPRequest.RESULT_SUCCESS
	print("Internet connection tested. Result: %s"%fl_internet_connection)
	emit_signal("internet_status_changed",fl_internet_connection)

