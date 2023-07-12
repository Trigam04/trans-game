extends Node

# !! Options breakdown at bottom

const defaults = {
	# Graphics
	"resolution": 3,
	"vsync": true,
	"ambientOcclusion": true,
	"shadowQuality": 4,
	# Graphics/Post Processing
	"bloom": 100,
	# Gamplay
	"baseFOV": 70,
	"fovEffects": 100
}

const low = {
	"ambientOcclusion": false,
	"shadowQuality": 1,
	"bloom": 0
}

var selected = defaults

# RESOLUTION
# The resolution to render the game at, NOT the size of the window
# 4: 1920x1200
# 3: 1920x1080
# 2: 1600x900
# 1: 1366x768

# VSYNC
# Whether to have vsync on or not

# SHADOW QUALITY
# 4: Ultra
# 3: High
# 2: Medium
# 1: Low



# BASE FOV
# The default FOV for normal circumstances

# FOV EFFECTS
# How much the FOV should be changed, such as when sprinting or crouching
# 0 for no change, 100 for 100% change
