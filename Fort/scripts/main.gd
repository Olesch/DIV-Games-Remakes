extends Node2D
## Main scene: spawns one normal and one zig-zag enemy every 100 frames (DIV main loop `FRAME(1000)`
## spawned every 10 frames; slowed 10x by owner decision 2026-10-26).

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const SPAWN_INTERVAL := 100.0 / 24.0  # ~4.17 s; owner decision 2026-10-26: 10x fewer enemies (was 10.0 / 24.0 = FRAME(1000), 10 frames @ 24 fps)

@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _damage_label: Label = $Hud/DamageLabel


func _ready() -> void:
	Game.damage = 0
	Game.enemies_shot = 0
	Game.damage_changed.connect(_on_damage_changed)
	_on_damage_changed(0)
	_spawn_timer.wait_time = SPAWN_INTERVAL
	_spawn_timer.timeout.connect(_spawn_wave)
	_spawn_wave()
	_spawn_timer.start()
	if "--autotest" in OS.get_cmdline_user_args():
		add_child(preload("res://scripts/debug/autotest.gd").new())


func _spawn_wave() -> void:
	for kind in [Enemy.Kind.NORMAL, Enemy.Kind.ZIGZAG]:
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		enemy.kind = kind
		enemy.position = _random_edge_position()
		add_child(enemy)


## DIV: each of the four edges has probability 1/4, 20 px outside the screen.
func _random_edge_position() -> Vector2:
	match randi_range(0, 3):
		0: return Vector2(-20, randi_range(0, 600))
		1: return Vector2(820, randi_range(0, 600))
		2: return Vector2(randi_range(0, 800), -20)
		_: return Vector2(randi_range(0, 800), 620)


func _on_damage_changed(value: int) -> void:
	_damage_label.text = "Schaden: %d" % value
