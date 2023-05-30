extends Control

@export var labelBox : VBoxContainer = null : set = set_container

# Internal Vars
var playerCoords : Vector3 = Vector3.ZERO
var playerState = null
var playerSpeed = null

var vals = {
	"vers": { "label": "Version", "val": Config.version, "node": null },
	"fps": { "label": "FPS", "val": "", "node": null },
	"playerCoords": { "label": "Coords", "val": "", "node": null },
	"playerState": { "label": "State", "val": "", "node": null },
	"playerSpeed": { "label": "Speed", "val": "", "node": null }
}

func _ready():
	labelBox.visible = false
	
	for item in vals.values():
		var label = Label.new()
		label.set_text(str(item.label) + ": " + str(item.val))
		item.node = label
		labelBox.add_child(label)

func _process(_delta):
	# Toggle
	if Input.is_action_just_pressed("debug_toggle"):
		labelBox.visible = !labelBox.visible
	# Update items
	updateItem("fps", Engine.get_frames_per_second())
	updateItem("playerCoords",
		"  X: " + str(Util.round_to_dec(playerCoords.x, 2)) +
		",  Y: " + str(Util.round_to_dec(playerCoords.y, 2)) +
		",  Z: " + str(Util.round_to_dec(playerCoords.z, 2))
	)
	updateItem("playerState", playerState)
	updateItem("playerSpeed", playerSpeed)
	
	# Update labels
	for item in vals.values():
		item.node.set_text(str(item.label) + ": " + str(item.val))

func updateItem(itemName, newVal):
	vals[itemName].val = newVal



# Setters/Getters
func set_container(newContainer):
	labelBox = newContainer
func set_player_coords(coords):
	playerCoords = coords
func set_player_state(newState):
	playerState = newState
func set_player_speed(newSpeed):
	playerSpeed = newSpeed
