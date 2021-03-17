extends Control



var response
var countries = []
var country = "canada"

onready var Selection = $Selection
onready var SearchBar = $Selection/SearchBar
onready var SearchResults = $Selection/SearchResults
onready var CountryOption = $Selection/CountryOption
onready var Error = $Selection/Error
onready var CountryCheck = $Selection/HTTPRequest
onready var StatCheck = $CanvasLayer/Alert/StatCheck
onready var Alert = $CanvasLayer/Alert
onready var StatsNumbers = $CanvasLayer/Alert/Stats2
onready var AnimPlay = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.window_per_pixel_transparency_enabled = true
	connect_signals()
	SearchBar.editable = false
	CountryOption.disabled = true
	CountryCheck.request("https://corona-rest-api.herokuapp.com/Api")



func connect_signals():
	CountryCheck.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	StatCheck.connect("request_completed", self, "_on_StatCheck_request_completed")
	CountryOption.connect("item_selected", self, "_on_CountryOption_item_selected")
	SearchBar.connect("text_changed", self, "_on_SearchBar_text_changed")
	SearchBar.connect("focus_entered", self, "_on_SearchBar_focus_entered")
	SearchBar.connect("focus_exited", self, "_on_SearchBar_focus_exited")
	SearchResults.connect("item_activated", self, "_on_SearchResults_item_activated")



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	response = parse_json(body.get_string_from_utf8())
	print(response["Success"].size())
	list_countries()



func list_countries():
	CountryOption.add_item("Select Country")
	CountryOption.set_item_disabled(0, true)
	for i in response["Success"]:
		countries.append(i["country"])
		countries.sort()
	for i in countries:
		CountryOption.add_item(i)
	SearchBar.editable = true
	CountryOption.disabled = false



func _on_CountryOption_item_selected(index):
	country = CountryOption.get_item_text(index)
	StatCheck.request("https://corona-rest-api.herokuapp.com/Api/%s" %country)
	Alert.visible = true



func _on_StatCheck_request_completed(result, response_code, headers, body):
	var results = parse_json(body.get_string_from_utf8())
	if results == null:
		Error.visible = true
		print(results)
	else:
		Selection.visible = false
		OS.window_size = OS.window_size/3
		OS.window_borderless = true
		OS.window_minimized = false
		get_tree().get_root().set_transparent_background(true)
		OS.window_position = OS.get_screen_size() - OS.window_size
		self.release_focus()
		AnimPlay.play("SwingUp")
		StatsNumbers.bbcode_text = "[color=yellow]%s[/color]\n\n[color=#ffa500]%s[/color]\n\n%s\n\n%s\n\n[color=red]%s[/color]\n\n[color=red]%s[/color]\n\n[color=green]%s[/color]\n\n[color=red]%s[/color]" %[country, results["Success"]["active"],results["Success"]["todayCases"], results["Success"]["cases"], results["Success"]["todayDeaths"], results["Success"]["deaths"], results["Success"]["recovered"], results["Success"]["critical"]]
		yield(get_tree().create_timer(5),"timeout")
		AnimPlay.play_backwards("SwingUp")
		yield(get_tree().create_timer(1),"timeout")
		OS.window_minimized = true
		yield(get_tree().create_timer(3600),"timeout")
		StatCheck.request("https://corona-rest-api.herokuapp.com/Api/%s" %country)



func _on_SearchBar_text_changed(new_text):
	SearchResults.clear()
	if new_text == "":
		SearchResults.visible = false
	else:
		SearchResults.visible = true
	for i in countries:
		if new_text.capitalize() in i:
			SearchResults.add_item(i)



func _on_SearchBar_focus_entered():
	if SearchBar.text == "":
		SearchResults.visible = true
		SearchResults.clear()
		for i in countries:
			SearchResults.add_item(i)



func _on_SearchBar_focus_exited():
	if SearchBar.text == "":
		SearchResults.visible = false



func _on_SearchResults_item_activated(index):
	country = SearchResults.get_item_text(index)
	StatCheck.request("https://corona-rest-api.herokuapp.com/Api/%s" %country)
	
