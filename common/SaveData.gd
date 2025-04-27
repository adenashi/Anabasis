class_name SaveData extends Node
## Stores player preference data, as well as any other data that needs to be saved between sessions.

#region Constants

## Path to whether the Save Data should be saved on the player's machine.
const PATH = "user://SaveData.cfg"

#endregion

#region Public Variables

static var GlobalVolume : float = 1.0
static var MusicVolume : float = 1.0
static var EffectsVolume : float = 1.0
static var Resolution : Vector2i = Vector2i(1920,1080)
static var FullScreen : bool = true
static var VSyncOn : bool = true
## Used to determine if any tutorial hints should be shown. 
static var TutorialOn : bool = true

static var BestTime : int = 0
static var BestReshuffles : int = -1
static var HighScore : int = 0

static var RecordsByStages : Dictionary = {
	1: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	2: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	3: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	4: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	5: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	6: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	7: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	8: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	9: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	10: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	11: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	12: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	13: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	14: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	15: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	16: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	17: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	18: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	19: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	},
	20: {
		"BestTime": 0,
		"BestReshuffles": -1,
		"HighScore": 0
	}
}


#endregion

#region Load Functions

static func load_data() -> void:
	var config = ConfigFile.new()
	
	if !FileAccess.file_exists(PATH):
		save_data()
		print("New Save File Created.")
	
	var result = config.load(PATH) # TODO : Change to Load Encrypted
	if result == OK:
		GlobalVolume = config.get_value("Settings", "GlobalVolume")
		MusicVolume = config.get_value("Settings", "MusicVolume")
		EffectsVolume = config.get_value("Settings", "EffectsVolume")
		Resolution = config.get_value("Settings", "Resolution")
		FullScreen = config.get_value("Settings", "FullScreen")
		VSyncOn = config.get_value("Settings", "VSyncOn")
		TutorialOn = config.get_value("Settings", "TutorialOn")
		load_records_by_stage(config)
	else:
		printerr("Error occurred while loading Save Data!")


static func load_records_by_stage(config : ConfigFile) -> void:
	var index : int = 1
	for record in config.get_sections():
		if record == "Settings":
			continue
		var best_time = config.get_value(record, "BestTime")
		var best_reshuffles = config.get_value(record, "BestReshuffles")
		var high_score = config.get_value(record, "HighScore")
		RecordsByStages[index] = {
			"BestTime": best_time,
			"BestReshuffles": best_reshuffles,
			"HighScore": high_score
		}
		index += 1


static func get_most_stages_cleared() -> int:
	var keys = RecordsByStages.keys()
	for i in range(keys.size() -1, -1, -1):
		if RecordsByStages[keys[i]].BestTime > 0:
			return keys[i]
	return 0


static func clear_records() -> void:
	for record in RecordsByStages:
		record.BestTime = 0
		record.BestReshuffles = -1
		record.HighScore = 0

#endregion

#region Save Functions

static func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("Settings", "GlobalVolume", GlobalVolume)
	config.set_value("Settings", "MusicVolume", MusicVolume)
	config.set_value("Settings", "EffectsVolume", EffectsVolume)
	config.set_value("Settings", "Resolution", Resolution)
	config.set_value("Settings", "FullScreen", FullScreen)
	config.set_value("Settings", "VSyncOn", VSyncOn)
	config.set_value("Settings", "TutorialOn", TutorialOn)
	save_records_by_stage(config)
	
	config.save(PATH) #TODO : Change to Encrypted Save


static func save_records_by_stage(config : ConfigFile) -> void:
	config.set_value("Record1", "BestTime", RecordsByStages[1].BestTime)
	config.set_value("Record1", "BestReshuffles", RecordsByStages[1].BestReshuffles)
	config.set_value("Record1", "HighScore", RecordsByStages[1].HighScore)
	
	config.set_value("Record2", "BestTime", RecordsByStages[2].BestTime)
	config.set_value("Record2", "BestReshuffles", RecordsByStages[2].BestReshuffles)
	config.set_value("Record2", "HighScore", RecordsByStages[2].HighScore)
	
	config.set_value("Record3", "BestTime", RecordsByStages[3].BestTime)
	config.set_value("Record3", "BestReshuffles", RecordsByStages[3].BestReshuffles)
	config.set_value("Record3", "HighScore", RecordsByStages[3].HighScore)
	
	config.set_value("Record4", "BestTime", RecordsByStages[4].BestTime)
	config.set_value("Record4", "BestReshuffles", RecordsByStages[4].BestReshuffles)
	config.set_value("Record4", "HighScore", RecordsByStages[4].HighScore)
	
	config.set_value("Record5", "BestTime", RecordsByStages[5].BestTime)
	config.set_value("Record5", "BestReshuffles", RecordsByStages[5].BestReshuffles)
	config.set_value("Record5", "HighScore", RecordsByStages[5].HighScore)
	
	config.set_value("Record6", "BestTime", RecordsByStages[6].BestTime)
	config.set_value("Record6", "BestReshuffles", RecordsByStages[6].BestReshuffles)
	config.set_value("Record6", "HighScore", RecordsByStages[6].HighScore)
	
	config.set_value("Record7", "BestTime", RecordsByStages[7].BestTime)
	config.set_value("Record7", "BestReshuffles", RecordsByStages[7].BestReshuffles)
	config.set_value("Record7", "HighScore", RecordsByStages[7].HighScore)
	
	config.set_value("Record8", "BestTime", RecordsByStages[8].BestTime)
	config.set_value("Record8", "BestReshuffles", RecordsByStages[8].BestReshuffles)
	config.set_value("Record8", "HighScore", RecordsByStages[8].HighScore)
	
	config.set_value("Record9", "BestTime", RecordsByStages[9].BestTime)
	config.set_value("Record9", "BestReshuffles", RecordsByStages[9].BestReshuffles)
	config.set_value("Record9", "HighScore", RecordsByStages[9].HighScore)
	
	config.set_value("Record10", "BestTime", RecordsByStages[10].BestTime)
	config.set_value("Record10", "BestReshuffles", RecordsByStages[10].BestReshuffles)
	config.set_value("Record10", "HighScore", RecordsByStages[10].HighScore)
	
	config.set_value("Record11", "BestTime", RecordsByStages[11].BestTime)
	config.set_value("Record11", "BestReshuffles", RecordsByStages[11].BestReshuffles)
	config.set_value("Record11", "HighScore", RecordsByStages[11].HighScore)
	
	config.set_value("Record12", "BestTime", RecordsByStages[12].BestTime)
	config.set_value("Record12", "BestReshuffles", RecordsByStages[12].BestReshuffles)
	config.set_value("Record12", "HighScore", RecordsByStages[12].HighScore)
	
	config.set_value("Record13", "BestTime", RecordsByStages[13].BestTime)
	config.set_value("Record13", "BestReshuffles", RecordsByStages[13].BestReshuffles)
	config.set_value("Record13", "HighScore", RecordsByStages[13].HighScore)
	
	config.set_value("Record14", "BestTime", RecordsByStages[14].BestTime)
	config.set_value("Record14", "BestReshuffles", RecordsByStages[14].BestReshuffles)
	config.set_value("Record14", "HighScore", RecordsByStages[14].HighScore)
	
	config.set_value("Record15", "BestTime", RecordsByStages[15].BestTime)
	config.set_value("Record15", "BestReshuffles", RecordsByStages[15].BestReshuffles)
	config.set_value("Record15", "HighScore", RecordsByStages[15].HighScore)
	
	config.set_value("Record16", "BestTime", RecordsByStages[16].BestTime)
	config.set_value("Record16", "BestReshuffles", RecordsByStages[16].BestReshuffles)
	config.set_value("Record16", "HighScore", RecordsByStages[16].HighScore)
	
	config.set_value("Record17", "BestTime", RecordsByStages[17].BestTime)
	config.set_value("Record17", "BestReshuffles", RecordsByStages[17].BestReshuffles)
	config.set_value("Record17", "HighScore", RecordsByStages[17].HighScore)
	
	config.set_value("Record18", "BestTime", RecordsByStages[18].BestTime)
	config.set_value("Record18", "BestReshuffles", RecordsByStages[18].BestReshuffles)
	config.set_value("Record18", "HighScore", RecordsByStages[18].HighScore)
	
	config.set_value("Record19", "BestTime", RecordsByStages[19].BestTime)
	config.set_value("Record19", "BestReshuffles", RecordsByStages[19].BestReshuffles)
	config.set_value("Record19", "HighScore", RecordsByStages[19].HighScore)
	
	config.set_value("Record20", "BestTime", RecordsByStages[20].BestTime)
	config.set_value("Record20", "BestReshuffles", RecordsByStages[20].BestReshuffles)
	config.set_value("Record20", "HighScore", RecordsByStages[20].HighScore)

#endregion
