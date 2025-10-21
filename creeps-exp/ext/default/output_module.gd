extends Node2D

func do_process(data: Dictionary) -> void:
	if data.has("text"):
		$Label.text = data["text"]
		$Timer.start(0.5)

func _on_timer_timeout() -> void:
	$Label.text = ""
