extends Node

func _ready():
  # TODO: initialize settings panel programmatically based on dict of settings ?
  pass

func _on_exit():
  # destroy modal
  self.queue_free()