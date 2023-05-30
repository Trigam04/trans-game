extends Node

# TODO: implement these
var savedScene = load("res://scenes/levels/move_test.tscn")

func _on_continue():
  get_tree().change_scene_to_packed(savedScene)

func _on_new_game():
  pass

func _on_options():
  # append options scene
  pass

func _on_quit():
  # goodbye!
  get_tree().quit(0)
