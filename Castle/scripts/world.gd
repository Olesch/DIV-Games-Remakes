class_name World
extends Node2D
## The game scene: the room background, the hero, all room entities and the HUD.
## DIV: main code after the menu + PROCESS Levelzeichner (draws the room and spawns its objects)
## + PROCESS Background (the 800x600 graphic 100 that the tiles are drawn into).

const HERO_SCENE := preload("res://scenes/hero.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const SHOT_SCENE := preload("res://scenes/shot.tscn")
const PICKUP_SCENE := preload("res://scenes/pickup.tscn")
const BLOOD_SCENE := preload("res://scenes/blood.tscn")

var hero: Hero
var _image: Image
var _texture: ImageTexture
var _tile_images: Dictionary = {}
var _dirty: bool = false

@onready var _background: Sprite2D = $Background
@onready var _entities: Node2D = $Entities
@onready var hud: Hud = $Hud


func _ready() -> void:
	Game.world = self
	# graph 100 starts fully transparent (black screen); tiles are blitted into it and stay there
	_image = Image.create(Game.SCREEN_W, Game.SCREEN_H, false, Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(_image)
	_background.texture = _texture
	_background.centered = false

	hero = HERO_SCENE.instantiate() as Hero
	hero.setup(Game.xhero, Game.yhero)
	add_child(hero)
	move_child(hero, 0)   # DIV: the hero is the first process, so it acts before everything else
	Game.hero = hero

	draw_room()
	hud.start(hero)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"back_to_title"):
		Game.to_title()


func _physics_process(_delta: float) -> void:
	_flush()


func _exit_tree() -> void:
	if Game.world == self:
		Game.world = null
		Game.hero = null


# ----------------------------------------------------------------- background tiles

func _tile_image(code: int) -> Image:
	if not _tile_images.has(code):
		var img := Gfx.tex(code).get_image()
		img.convert(Image.FORMAT_RGBA8)
		_tile_images[code] = img
	return _tile_images[code]


## DIV: map_put(0, 100, tile, gx*20, gy*20)
func put_tile(code: int, gx: int, gy: int) -> void:
	var img := _tile_image(code)
	_image.blend_rect(img, Rect2i(0, 0, img.get_width(), img.get_height()), Vector2i(gx * Game.TILE, gy * Game.TILE))
	_dirty = true


func _flush() -> void:
	if _dirty:
		_texture.update(_image)
		_dirty = false


## DIV: PROCESS Levelzeichner - draws all 40x30 terrain tiles of the current room and spawns the
## enemies and pickups from the object layer. Cells whose terrain value has no case (0) keep
## whatever was drawn before, exactly like the original.
func draw_room() -> void:
	var additional := 0
	if Game.stat.level > 4:
		additional += 1
	if Game.stat.level > 8:
		additional += 1
	for gy in Game.ROWS:
		for gx in Game.COLS:
			var field := Game.cell(0, gx, gy)
			var picture := 0
			match field:
				6:
					picture = randi_range(101, 104) if randi_range(0, 10) == 0 else 101
				22:
					picture = randi_range(110, 112) if randi_range(0, 10) == 0 else 110
				20:
					picture = randi_range(111, 112)
				26:
					picture = 120
				28:
					picture = 121
				71:
					picture = 125
				40:
					picture = 132
				212:
					picture = 130
				211:
					picture = 101
				213:
					picture = 101
				214:
					picture = 131
				11:
					picture = 126
			if picture != 0:
				put_tile(picture, gx, gy)
			if gx == 39 and gy == 29:
				put_tile(113, gx, gy)

			var cx := gx * Game.TILE + 10
			var cy := gy * Game.TILE + 10
			match Game.cell(1, gx, gy):
				7:
					spawn_pickup(69, 1, cx, cy)
				22:
					spawn_pickup(60, randi_range(5, 20), cx, cy)
				20:
					spawn_pickup(61, randi_range(15, 25), cx, cy)
				54:
					spawn_pickup(63, randi_range(6, 8), cx, cy)
				52:
					spawn_pickup(64, randi_range(20, 30), cx, cy)
				118:
					spawn_pickup(66, randi_range(1, 3), cx, cy)
				116:
					spawn_pickup(67, randi_range(7, 13), cx, cy)
				71:
					spawn_pickup(127, 1, cx, cy)
				74:
					spawn_pickup(74, 100, cx, cy)
				11:
					spawn_pickup(128, 1, cx, cy)
				250:
					spawn_pickup(72, 1, cx, cy)
				120:
					spawn_pickup(75, 1, cx, cy)
				121:
					spawn_pickup(76, 1, cx, cy)
				122:
					spawn_pickup(77, 1, cx, cy)
				59:
					spawn_pickup(78, 1, cx, cy)
				60:
					spawn_pickup(79, 1, cx, cy)
				61:
					spawn_pickup(80, 1, cx, cy)
				# Enemy(Initgraph, Life, Strength, x, y, DefRad, exp, weapon, resist, spec)
				41:  # Ork
					spawn_enemy(200, randi_range(10, 20), randi_range(3, 5) + additional, cx, cy,
						randi_range(70, 100), 10, 0, 0, 0)
				40:  # HelmOrk
					spawn_enemy(210, randi_range(30, 50), randi_range(6, 8) + additional, cx, cy,
						randi_range(100, 130), 25, 0, 40, 0)
				39:  # OrkSchuetze (archer)
					spawn_enemy(205, randi_range(10, 20), randi_range(4, 6) + additional, cx, cy,
						5000, 15, 1, 0, 0)
				38:  # OrkHeld (hero ork, two weapon style)
					spawn_enemy(220, randi_range(300, 320), randi_range(18, 20), cx, cy,
						5000, 160, 0, 40, 2)
				17:  # Ogre
					spawn_enemy(215, randi_range(190, 220), randi_range(13, 15), cx, cy,
						80, 80, 0, 300, 1)
				18:  # OgreStonethrower
					spawn_enemy(230, randi_range(190, 220), randi_range(22, 27), cx, cy,
						5000, 110, 2, 300, 1)
				13:  # Ghost
					spawn_enemy(225, randi_range(80, 90), randi_range(10, 11), cx, cy,
						120, 90, 0, 88, 3)
	_flush()


# ----------------------------------------------------------------- spawning

func spawn_enemy(initgraph: int, life: int, strength: int, px: int, py: int, defrad: int,
		expgive: int, weapon: int, resist: int, spec: int) -> void:
	var e := ENEMY_SCENE.instantiate() as Enemy
	e.setup(initgraph, life, strength, px, py, defrad, expgive, weapon, resist, spec)
	_entities.add_child(e)


func spawn_pickup(graph: int, power: int, px: int, py: int) -> void:
	var p := PICKUP_SCENE.instantiate() as Pickup
	p.setup(graph, power, px, py)
	_entities.add_child(p)


func spawn_shot(px: int, py: int, dir: int, strength: int, steps: int, graph: int, nummer: int) -> void:
	var s := SHOT_SCENE.instantiate() as Shot
	s.setup(px, py, dir, strength, steps, graph, nummer)
	_entities.add_child(s)


func spawn_blood(px: int, py: int, angle_thousandths: int, power: int) -> void:
	var b := BLOOD_SCENE.instantiate() as Blood
	b.setup(px, py, angle_thousandths, power)
	_entities.add_child(b)


## DIV: Otherlevel=1 makes every enemy, pickup and shot end. Blood splashes finish on their own.
func clear_room_entities() -> void:
	for n in _entities.get_children():
		if n is Enemy or n is Pickup or n is Shot:
			if n is Enemy:
				n.remove_from_group(&"enemies")
			if n is Pickup:
				n.remove_from_group(&"pickups")
			n.queue_free()


## DIV: let_me_alone() when the hero dies - everything else vanishes, the screen goes black.
func begin_death() -> void:
	for n in _entities.get_children():
		if n is Enemy:
			n.remove_from_group(&"enemies")
		n.queue_free()
	_background.visible = false
	hud.visible = false
