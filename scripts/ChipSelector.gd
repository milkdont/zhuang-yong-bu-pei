extends HBoxContainer
class_name ChipSelector
## 籌碼選擇列

signal chip_changed(amount: int)

var chips: Array[int] = [1000, 5000, 10000, 50000, 100000, 500000, 1000000, 5000000, 10000000, 50000000, 100000000]
var selected: int = 1000
var _btns: Dictionary = {}

func _ready() -> void:
	add_theme_constant_override("separation", 6)
	for c in chips:
		var b := Button.new()
		b.text = _short(c)
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(72, 32)
		b.pressed.connect(_on_pressed.bind(c))
		add_child(b)
		_btns[c] = b
	_update_visual()

func _short(n: int) -> String:
	if n >= 1_000_000_000:
		return "%dB" % int(n / 1_000_000_000)
	if n >= 1_000_000:
		return "%dM" % int(n / 1_000_000)
	if n >= 1000:
		return "%dK" % int(n / 1000)
	return str(n)

func _on_pressed(c: int) -> void:
	selected = c
	_update_visual()
	chip_changed.emit(selected)

func _update_visual() -> void:
	for c in _btns:
		var b: Button = _btns[c]
		b.button_pressed = (c == selected)
		b.disabled = c > GameState.cash and c != selected

func refresh_affordability() -> void:
	_update_visual()
	if selected > GameState.cash:
		## 自動降到負擔得起嘅最大籌碼
		var best := 0
		for c in chips:
			if c <= GameState.cash:
				best = c
		if best > 0:
			selected = best
			_update_visual()
			chip_changed.emit(selected)
