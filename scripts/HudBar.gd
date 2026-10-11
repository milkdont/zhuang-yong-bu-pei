extends PanelContainer
class_name HudBar
## 共用 HUD：現金、距 1 億／20 億、累計損益、莊家優勢備註

@onready var cash_label: Label = %CashLabel
@onready var d100_label: Label = %D100Label
@onready var d2b_label: Label = %D2BLabel
@onready var pl_label: Label = %PLLabel
@onready var edge_label: Label = %EdgeLabel
@onready var greed_label: Label = %GreedLabel

func _ready() -> void:
	GameState.cash_changed.connect(func(_v): refresh())
	GameState.stats_changed.connect(refresh)
	refresh()

func refresh() -> void:
	cash_label.text = "現金：" + GameState.format_money(GameState.cash)
	d100_label.text = "距一億：" + GameState.format_money(GameState.distance_to_100m())
	d2b_label.text = "距二十億：" + GameState.format_money(GameState.distance_to_2b())
	var pl := GameState.net_pl()
	if pl >= 0:
		pl_label.text = "累計損益：+" + GameState.format_money(pl)
	else:
		pl_label.text = "累計損益：" + GameState.format_money(pl)
	edge_label.text = GameState.house_edge_notes()
	if GameState.reached_100m:
		greed_label.text = GameState.last_greed_message if GameState.last_greed_message != "" else "贏返本唔夠爽——唔係而家衝，更待何時？"
		greed_label.visible = true
	else:
		greed_label.visible = false
