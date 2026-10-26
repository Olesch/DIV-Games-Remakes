class_name Defs
extends RefCounted
## Shared constants and enums for Minicosm.

## DIV: set_fps(24, 0). All "per frame" values of the original are multiplied by this.
const FPS := 24.0
## DIV: set_mode(m1024x768)
const SCREEN_SIZE := Vector2(1024.0, 768.0)
## Meteors that pass this y explode on the ground (DIV: IF(y>710)).
const GROUND_Y := 710.0
## DIV: the buy menu is the strip mouse.y<61; cannons only shoot below it (mouse.y>60).
const MENU_HEIGHT := 61.0
## Maximum ammo capacity per cannon (DIV: LeftShootMunitionMax<6).
const MAX_AMMO := 6

enum Side { LEFT, RIGHT }

## Entries of the buy menu (DIV: KaufMenuKnoepfe graphics 200..218).
enum Item {
    LEFT_CANNON, RIGHT_CANNON, DUK, POTION, BIRD, ATOM, SECOND_PLAYER,
    RELOAD, ROCKET, BIRD_BREEDING, POTION_LIMIT, MAGNET,
}

## DIV: Meteor "Art" 0..4
enum MeteorKind { NORMAL, IRON, DOUBLE, DOUBLE_IRON, DOUBLE_IRON_CRACKED }
