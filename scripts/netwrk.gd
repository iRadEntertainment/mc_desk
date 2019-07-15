#====================#
#     netwrk.gd      #
#====================#
extends Node

const PORT        = 5000
const ADDRESS     = "81.4.107.146" #"127.0.0.1" #"81.4.107.146"
const MAX_CONNECTION_ATTEMPTS = 10

#network
signal network_status_changed

var established = false setget _set_established
var logged_in   = false
var net_id      = -1

func _ready():
	#connect network signals
	get_tree().multiplayer.connect("network_peer_packet",self,"_on_packets_received")
	get_tree().connect("connected_to_server",self,"_on_connection_succeeded")
	get_tree().connect("connection_failed",self,"_on_connection_failed")
	
	get_tree().connect("network_peer_connected", self, "_on_user_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_user_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

func connect_to():
	var host = NetworkedMultiplayerENet.new()
	var res = host.create_client(ADDRESS,PORT)
	
	if res != OK:
		glb.log_print ("NETWORK: Impossible to create client")
		glb.log_print (str("NETWORK: Error:",res) )
		return
	else:
		glb.log_print ("NETWORK: connecting to server...")
	get_tree().set_network_peer(host)
	net_id = get_tree().multiplayer.get_network_unique_id()

func disconnect_from():
	get_tree().set_network_peer(null)
	self.established = false

#----------------- network signal functions ---------------------
var connection_attempt = 0
func _on_connection_failed():
#	$scr/bg/lb_print.text = str($scr/bg/lb_print.text,"\n","Connection failed - ","Error: ")
	get_tree().set_network_peer(null)
	self.established = false
	glb.log_print("NETWORK: connection failed")
	connection_attempt += 1
	if connection_attempt <= MAX_CONNECTION_ATTEMPTS:
		glb.log_print( ("NETWORK: retrying... attempt n. "+str(connection_attempt)) )
		
	
func _on_connection_succeeded():
#	$scr/bg/lb_print.text = str($scr/bg/lb_print.text,"\n","Connection succeded - ")
	glb.log_print("NETWORK: connection succeeded")
	self.established = true
	connection_attempt = 0

#----------------- network communications ---------------------

func _on_packets_received(id,packet):
	#id == 1: id = "Server"
	pass

func _on_user_connected(id):    glb.log_print("NETWORK: user connected %s"%id)
func _on_user_disconnected(id): glb.log_print("NETWORK: user disconnected %s"%id)
func _on_server_disconnected():
	glb.log_print("NETWORK: server disconnected")
	self.established = false

func send_msg_data(dat, id = 0):
	#id == 0: all peers
	var err = get_tree().multiplayer.send_bytes(var2bytes(dat),id)
	if err == OK:
		glb.log_print( "NETWORK: -> %s - %s"%[ id , dat ] )
	else:
		glb.log_print( "NETWORK: unable to send %s - %s\nError: %s"%[ id , dat , err] )


#

func _set_established(val):
	established = val
	emit_signal("network_status_changed",val)