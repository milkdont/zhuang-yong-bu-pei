extends SceneTree
func _init() -> void:
	call_deferred("_go")
func _go() -> void:
	var scenes := [
		"res://scenes/MainMenu.tscn",
		"res://scenes/Intro.tscn",
		"res://scenes/CasinoHub.tscn",
		"res://scenes/Roulette.tscn",
		"res://scenes/Baccarat.tscn",
		"res://scenes/Slots.tscn",
		"res://scenes/Ending.tscn",
		"res://scenes/HudBar.tscn",
	]
	for p in scenes:
		var ps = load(p)
		if ps == null:
			push_error("FAIL load " + p)
			quit(1)
			return
		var n = ps.instantiate()
		if n == null:
			push_error("FAIL inst " + p)
			quit(1)
			return
		root.add_child(n)
		await process_frame
		n.queue_free()
		await process_frame
		print("[Validate] OK ", p)
	print("[Validate] ALL SCENES OK")
	quit(0)
