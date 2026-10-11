extends SceneTree
## Headless smoke test
## godot --headless --path /workspace/anti-gambling-demo -s res://scripts/SmokeTest.gd

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("[Smoke] start")
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		push_error("GameState autoload missing")
		quit(1)
		return

	gs.reset()
	_eq(gs.cash, 100_000, "start cash")

	# Logic classes (class_name) — available after project load
	_eq(RouletteLogic.resolve(RouletteLogic.BetKind.RED, 1000, 0), 0, "zero beats red")
	_eq(RouletteLogic.resolve(RouletteLogic.BetKind.STRAIGHT, 1000, 17, 17), 36000, "straight payout")

	var hand_b := {"winner": "banker", "pt": 5, "bt": 6, "player": [], "banker": []}
	_eq(BaccaratLogic.resolve(BaccaratLogic.Side.BANKER, 10000, hand_b), 19500, "banker 5%")
	var hand_t := {"winner": "tie", "pt": 7, "bt": 7, "player": [], "banker": []}
	_eq(BaccaratLogic.resolve(BaccaratLogic.Side.PLAYER, 5000, hand_t), 5000, "tie refund")

	var rtp: float = SlotsLogic.theoretical_rtp()
	print("[Smoke] slots RTP=", rtp)
	if abs(rtp - 0.96) > 0.001:
		push_error("RTP not ~96%")
		quit(1)
		return

	gs.reset()
	gs.apply_bet_result(0, 100_000_000, "roulette")
	if not gs.reached_100m:
		push_error("should reach 100m")
		quit(1)
		return
	gs.apply_bet_result(gs.cash, 0, "slots")
	_eq(gs.ending_id, "relapse", "relapse ending")

	gs.reset()
	gs.apply_bet_result(0, 2_000_000_000, "roulette")
	if not gs.can_true_stop():
		push_error("should can true stop cash=%d" % gs.cash)
		quit(1)
		return
	gs.request_true_stop()
	_eq(gs.ending_id, "peak", "peak ending")

	gs.reset()
	gs.apply_bet_result(100_000, 0, "baccarat")
	_eq(gs.ending_id, "broke", "broke ending")

	print("[Smoke] ALL PASSED")
	quit(0)

func _eq(a, b, msg: String) -> void:
	if a != b:
		push_error("ASSERT %s: got %s expected %s" % [msg, str(a), str(b)])
		print("[Smoke] FAIL ", msg, " got=", a, " expected=", b)
		quit(1)
