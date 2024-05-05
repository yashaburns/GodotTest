extends Area2D

@onready var timer = $Timer
@onready var audio_stream_player = $AudioStreamPlayer2D

func _on_body_entered(body):
	print("You died!")
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	timer.start()
	audio_stream_player.play()


func _on_timer_timeout():
	get_tree().reload_current_scene()
	Engine.time_scale = 1
