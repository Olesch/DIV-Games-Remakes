class_name Gfx
extends RefCounted
## Helpers for the converted DIV graphics (assets/fpg/minicosm).
## DIV places a graphic by its control point 0; Sprite2D nodes use offset = -cp0.

const DIR := "res://assets/fpg/minicosm/"

## Control point 0 of every graphic used (from assets/fpg/minicosm/meta.json; centre if undefined).
const CP0 := {
    1: Vector2(25, 25), 2: Vector2(25, 25), 3: Vector2(25, 25), 4: Vector2(25, 25),
    5: Vector2(25, 25), 6: Vector2(25, 25), 7: Vector2(25, 25), 8: Vector2(25, 25),
    10: Vector2(0, 149), 11: Vector2(0, 149), 12: Vector2(0, 19),
    13: Vector2(29, 35), 14: Vector2(29, 35),
    15: Vector2(149, 149), 16: Vector2(149, 149),
    17: Vector2(30, 15), 18: Vector2(30, 15), 19: Vector2(12, 12),
    20: Vector2(22, 17), 21: Vector2(22, 17), 22: Vector2(22, 17), 23: Vector2(22, 17),
    25: Vector2(40, 40), 26: Vector2(40, 40),
    27: Vector2(80, 40), 28: Vector2(80, 40), 29: Vector2(80, 40),
    30: Vector2(40, 40), 31: Vector2(40, 40), 32: Vector2(40, 40), 33: Vector2(40, 40), 34: Vector2(40, 40),
    36: Vector2(14, 12), 37: Vector2(14, 12), 38: Vector2(17, 17),
    100: Vector2(512, 384),
}
const MENU_BUTTON_CP0 := Vector2(30, 45)

static var _textures: Dictionary = {}


static func tex(code: int) -> Texture2D:
    if not _textures.has(code):
        _textures[code] = load("%s%d.png" % [DIR, code])
    return _textures[code]


static func cp0(code: int) -> Vector2:
    if code >= 199 and code <= 218:
        return MENU_BUTTON_CP0
    return CP0.get(code, Vector2.ZERO)


## Show graphic `code` on a Sprite2D so that the node position is the DIV (x, y).
static func apply(sprite: Sprite2D, code: int) -> void:
    sprite.centered = false
    sprite.texture = tex(code) if code > 0 else null
    sprite.offset = -cp0(code)


## Fill an AnimatedSprite2D. `anims` = {name: {"frames": [[code, duration_in_frames], ...], "loop": bool}}.
## DIV animations change `graph` every n frames, so durations are given in DIV frames
## and the animation speed is the game's fps.
static func setup_animated(sprite: AnimatedSprite2D, anims: Dictionary) -> void:
    var frames := SpriteFrames.new()
    frames.remove_animation(&"default")
    var first_code := -1
    for anim_name: StringName in anims:
        var def: Dictionary = anims[anim_name]
        frames.add_animation(anim_name)
        frames.set_animation_speed(anim_name, Defs.FPS)
        frames.set_animation_loop(anim_name, def.get("loop", true))
        for entry: Array in def["frames"]:
            if first_code < 0:
                first_code = entry[0]
            frames.add_frame(anim_name, tex(entry[0]), float(entry[1]))
    sprite.sprite_frames = frames
    sprite.centered = false
    sprite.offset = -cp0(first_code)


## DIV out_region(id, 0): the (rotated) graphic's bounding box is completely outside the screen.
static func is_outside_screen(pos: Vector2, size: Vector2, rot: float) -> bool:
    var c := absf(cos(rot))
    var s := absf(sin(rot))
    var half := Vector2(c * size.x + s * size.y, s * size.x + c * size.y) * 0.5
    return (pos.x + half.x < 0.0 or pos.x - half.x > Defs.SCREEN_SIZE.x
        or pos.y + half.y < 0.0 or pos.y - half.y > Defs.SCREEN_SIZE.y)
