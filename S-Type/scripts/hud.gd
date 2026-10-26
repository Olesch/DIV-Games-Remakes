class_name Hud
extends CanvasLayer
## DIV write()/write_int() texts: lives counters in the corners (fonts 2, 3, 4, 1), the boss life
## readout, level messages, and the fade-out used when the game ends.

var _lives_labels: Array = []   # [PixelLabel, player index]
var _fade: ColorRect


func _ready() -> void:
	layer = 10
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.size = Game.SCREEN
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	move_child(_fade, 0)


func setup_lives() -> void:
	# DIV: write_int(font, x, y, align, OFFSET Player[n].lives); only P1 when lives are shared
	var defs := [[2, 0, 35, 0], [3, 800, 35, 2], [4, 0, 600, 6], [1, 800, 600, 8]]
	for i in Game.player_count:
		if i > 0 and Game.shared_lives == 1:
			break
		var d: Array = defs[i]
		_lives_labels.append([PixelLabel.make(self, d[0], d[1], d[2], d[3], "0"), i])


func say(text: String, x: float, y: float, align: int) -> PixelLabel:
	return PixelLabel.make(self, 1, x, y, align, text)


## write_int(1,750,550,8,OFFSET boss.life)
func show_life(boss: Node) -> PixelLabel:
	var l := PixelLabel.make(self, 1, 750, 550, 8, "")
	l.set_meta(&"boss", boss)
	return l


func _process(_delta: float) -> void:
	for entry in _lives_labels:
		var lives := maxi(Game.players[entry[1]].lives, 0)
		(entry[0] as PixelLabel).set_value(str(lives))
	for c in get_children():
		if c is PixelLabel and c.has_meta(&"boss"):
			var boss: Variant = c.get_meta(&"boss")
			if is_instance_valid(boss):
				(c as PixelLabel).set_value(str((boss as Enemy).life))


## DIV fade_off(): fade to black, then call `done`.
func fade_out(done: Callable) -> void:
	var t := create_tween()
	t.tween_property(_fade, "color:a", 1.0, 0.4)
	t.tween_callback(done)
