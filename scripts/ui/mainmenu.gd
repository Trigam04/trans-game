extends Node

@export var options_scene: PackedScene;

# TODO: implement these
var savedScene = load("res://scenes/levels/move_test.tscn")

func _on_continue():
  get_tree().change_scene_to_packed(savedScene)

func _on_new_game():
  pass

func _on_options():
  var _overlay = options_scene.instantiate();
  self.add_child(_overlay)

func _on_quit():
  # goodbye!
  get_tree().quit(0)
