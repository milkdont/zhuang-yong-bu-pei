extends RefCounted
class_name BaccaratLogic
## 簡化百家樂：只賭閒／莊。標準點數與補牌規則。
## 閒注 1:1（和則退本）；莊注贏扣 5% 佣金。
## 理論莊家優勢：莊 ≈1.06%，閒 ≈1.24%

enum Side { PLAYER, BANKER }

static func _card_value(card: int) -> int:
	## card 1–13；A=1, 2–9=面值, 10/J/Q/K=0
	var r: int = ((card - 1) % 13) + 1
	if r >= 10:
		return 0
	return r

static func _draw_card() -> int:
	return randi() % 52  # 0–51

static func _hand_total(cards: Array) -> int:
	var t: int = 0
	for c in cards:
		t += _card_value(int(c) + 1)
	return t % 10

static func _deal_natural_or_draw() -> Dictionary:
	var player: Array = [_draw_card(), _draw_card()]
	var banker: Array = [_draw_card(), _draw_card()]
	var pt: int = _hand_total(player)
	var bt: int = _hand_total(banker)
	## Natural
	if pt >= 8 or bt >= 8:
		return {"player": player, "banker": banker, "pt": pt, "bt": bt}
	## Player third card rule
	var p3: int = -1
	if pt <= 5:
		p3 = _draw_card()
		player.append(p3)
		pt = _hand_total(player)
	## Banker third card rules
	if p3 < 0:
		## player stood
		if bt <= 5:
			banker.append(_draw_card())
			bt = _hand_total(banker)
	else:
		var p3v: int = _card_value(p3 + 1)
		var draw: bool = false
		if bt <= 2:
			draw = true
		elif bt == 3:
			draw = p3v != 8
		elif bt == 4:
			draw = p3v >= 2 and p3v <= 7
		elif bt == 5:
			draw = p3v >= 4 and p3v <= 7
		elif bt == 6:
			draw = p3v == 6 or p3v == 7
		## bt == 7 stand
		if draw:
			banker.append(_draw_card())
			bt = _hand_total(banker)
	return {"player": player, "banker": banker, "pt": pt, "bt": bt}

static func play_hand() -> Dictionary:
	var h: Dictionary = _deal_natural_or_draw()
	var winner: String = "tie"
	if int(h.pt) > int(h.bt):
		winner = "player"
	elif int(h.bt) > int(h.pt):
		winner = "banker"
	h["winner"] = winner
	return h

static func resolve(side: int, wager: int, hand: Dictionary) -> int:
	## 派彩總額（含本）；和局退本 = wager；輸 = 0
	var w: String = str(hand.winner)
	if w == "tie":
		return wager
	if side == Side.PLAYER:
		if w == "player":
			return wager * 2
		return 0
	else:
		if w == "banker":
			## 5% commission on win profit
			var profit: int = wager
			var commission: int = int(floor(float(profit) * 0.05))
			return wager + profit - commission
		return 0

static func card_label(card_idx: int) -> String:
	var ranks: PackedStringArray = PackedStringArray(["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"])
	var suits: PackedStringArray = PackedStringArray(["♠", "♥", "♦", "♣"])
	var r: String = ranks[card_idx % 13]
	var s: String = suits[int(card_idx / 13) % 4]
	return s + r
