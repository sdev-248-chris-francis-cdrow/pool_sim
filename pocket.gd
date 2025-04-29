extends CollisionShape3D

var balls:int = 15

signal qreset

func reset_qball(body) -> void:
	if not is_instance_valid(body):
		return
	body.global_position = Vector3(0, 0.105, 1) # wherever the cue ball starts
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	qreset.emit()

func reset_ball(body) -> void:
	if not is_instance_valid(body):
		return
	body.global_position = Vector3(0, 0.105, -0.7) # wherever the cue ball starts
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
	
func remove_ball(body) -> void:
	if not is_instance_valid(body):
		return
	body.queue_free()
	balls -=1
	if balls <= 0:
		call_deferred("reset_game")
	
	
func _on_pockets_body_entered(body: Node3D) -> void:
	if body.name == "CueBall":
		# Reset cue ball
		call_deferred("reset_qball", body)
		var cue = get_node("/root/main/cue")
		if cue:
			print(cue)
			cue.reset()
	elif body.is_in_group("balls"):
		call_deferred("remove_ball", body)


func _on_tablebounds_body_exited(body: Node3D) -> void:
	if body.name == "CueBall":
		# Reset cue ball
		call_deferred("reset_qball", body)
	elif body.is_in_group("balls"):
		call_deferred("reset_ball", body)

func reset_game() -> void:
	call_deferred("reset")

func reset() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
