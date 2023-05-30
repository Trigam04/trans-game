extends Node

func tweenVal(target, prop, to, secs):
	var tween = get_tree().create_tween()
	tween.tween_property(target, prop, to, secs)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func get_enum_val_as_string(targetEnum, val):
	return targetEnum.keys()[val]
