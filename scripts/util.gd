extends Node

func tweenVal(target, prop, to, secs):
	var tween = get_tree().create_tween()
	tween.tween_property(target, prop, to, secs)

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func get_enum_val_as_string(targetEnum, val):
	return targetEnum.keys()[val]

func get_child_of_type(node: Node, child_type):
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		if is_instance_of(child, child_type):
			return child

func get_children_of_type(node: Node, child_type):
	var list = []
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		if is_instance_of(child, child_type):
			list.append(child)
	return list
