extends ProgressBar

func _process(delta):
	if value <= 100:
		value += 3.5*delta
