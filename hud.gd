extends CanvasLayer

var hud_power = 0

func float_to_percent(value: float) -> String:
	var percent: float = clamp(value / 2.0, 0.0, 1.0) * 100.0
	return "%03d%%" % int(percent)



func _on_cue_changed_power(power: float) -> void:
	hud_power = power
	$Label.text = float_to_percent(hud_power)
