#=====================#
#     DATA_MNG.GD     #
#=====================#
extends Node

#---------- config_files
var data_dir  = "res://"#str(OS.get_system_dir(0))
var data_filename = "mc_data.cfg"
var data_path = str(data_dir,data_filename)

#---------- config_files
var console_log = [] setget _log_updated
signal log_updated

#---------- user preferences


#---------- datas
var last_update_list = {}

var balance_path     = str(data_dir,"mc_data_balance.cfg")
var balance_register = [] # [unixdate_operation_0, unix_date_operation_1, ...]
var balance_dic      = {} # id_op : {field: value, ...} , id_op {}, ...

func _ready():
	load_initial_settings()
	check_updated_datas_from_server()


#------------------------------ config file: save/load/create ---------------------------

func load_initial_settings():
	glb.log_print("DATA MANAGER: loading initial settings")
	var dir = Directory.new()
	if dir.open(data_dir) != OK:
		glb.log_print("DATA MANAGER: Unexisting folder")
		create_default_config()
	elif not Directory.new().file_exists(data_path):
		glb.log_print("DATA MANAGER: no config file!")
		create_default_config()
	else:
		var file_config = ConfigFile.new()
		file_config.load(data_path)
		console_log      = file_config.get_value("settings", "console_log", [] )
		last_update_list = file_config.get_value("updates", "last_update_list", {})
		glb.last_auth    = file_config.get_value("user","last_auth",[])
		
	
	#load datas
	if Directory.new().file_exists(balance_path):
		var file_balance = ConfigFile.new()
		file_balance.load(balance_path)
		balance_register = file_balance.get_value("balance","register",[])
		balance_dic      = file_balance.get_value("balance","dictionary",{})

func create_default_config():
	glb.log_print("DATA MANAGER: creating default file")
	var dir = Directory.new()
	if dir.open(data_dir) != OK:
		var err_dir = dir.make_dir_recursive(data_dir)
		if err_dir == OK:
			glb.log_print( str ("DATA MANAGER: folder created -> ", data_dir) )
		else:
			glb.log_print(str ("DATA MANAGER: Unable to create folder -> Error ",err_dir))
	
	#--------- default values
	save_data()

func save_data(what_to_save_array = []):
	if what_to_save_array == []:
		what_to_save_array = ["config","balance"]
	
	for what in what_to_save_array:
		match what:
			"config":
				glb.log_print("DATA MANAGER: saving mc_data.cfg")
				var file_config = ConfigFile.new()
				file_config.set_value("settings","console_log",console_log)
				file_config.set_value("user","last_auth",glb.last_auth)
				
				var err_cfg = file_config.save(data_path)
				if err_cfg == OK: glb.log_print(str ("DATA MANAGER: data file saved = ", data_path))
				else:             glb.log_print(str ("DATA MANAGER: unable to save data file -> Error ", err_cfg))
			"balance":
				glb.log_print("DATA MANAGER: saving mc_data_balance.cfg")
				var file_balance = ConfigFile.new()
				file_balance.set_value("balance", "register",   balance_register)
				file_balance.set_value("balance", "dictionary", balance_dic)
				
				var err_cfg = file_balance.save(balance_path)
				if err_cfg == OK:
					glb.log_print(str ("DATA MANAGER: balance file saved = ", balance_path))
					save_update_list("balance") # <======= IMPORTANT
				else:
					glb.log_print(str ("DATA MANAGER: unable to save balance file -> Error ", err_cfg))
			_:
				prints("wrong what_to_save value:", what)
	
	#--- update server if connected, else, store future updates
	# TODO
	


#-------------------------- updates from server/store updates TODO list --------------------------
func save_update_list(field):
	if typeof(field) == TYPE_STRING:
		var file_config = ConfigFile.new()
		last_update_list[field] = OS.get_unix_time()
		file_config.set_value("updates","last_update_list",last_update_list)
		file_config.save(data_path)

func check_updated_datas_from_server():
#	TODO compare client data with Server data and update accordingly
	if last_update_list.has("balance"):
		print("last update list['balance'] = ",last_update_list["balance"])
	pass


#----------------------------------------------- set_get ------------------------------

func _log_updated(val):
	console_log = val
	emit_signal("log_updated",console_log)
