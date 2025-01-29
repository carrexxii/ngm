# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common
from std/strutils import to_hex

type # [a, b, g, r] / 0xAABBGGRR
    ColourF32* = distinct array[4, float32]
    ColourU8*  = distinct array[4, uint8]

    AColour* = ColourF32 | ColourU8

    Colour* = ColourU8

func `[]`*(c: ColourF32; i: int): float32 = cast[array[4, float32]](c)[i]
func `[]`*(c: ColourU8; i: int): uint8    = cast[array[4, uint8]](c)[i]
func `[]=`*(c: var ColourF32; i: int; val: float32) = c[i] = val
func `[]=`*(c: var ColourU8; i: int; val: uint8)    = c[i] = val

const VectorFields = ["abgr"]
type Swizzleable = AColour
include swizzle

{.push inline.}

converter to_colouru8*(arr: array[4, uint8]): ColourU8     = ColourU8  arr
converter to_colourf32*(arr: array[4, float32]): ColourF32 = ColourF32 arr

converter to_colourf32*(c: ColourU8): ColourF32 =
    [(float32 c.a) / 255,
     (float32 c.b) / 255,
     (float32 c.g) / 255,
     (float32 c.r) / 255]
converter to_colouru8*(c: ColourF32): ColourU8 =
    [uint8(c.a * 255),
     uint8(c.b * 255),
     uint8(c.g * 255),
     uint8(c.r * 255)]

func to_uint32*(c: ColourU8): uint32 =
    ((uint32 c.a) shl 24) and
    ((uint32 c.b) shl 16) and
    ((uint32 c.g) shl 8 ) and uint32 c.r
func to_uint32*(c: ColourF32): uint32 = to_uint32 to_colouru8 c

func colour*(r, g, b: uint8; a = 255'u8): ColourU8   = [a, b, g, r]
func colour*(r, g, b: float32; a = 1'f32): ColourF32 = [a, b, g, r]

proc colour*(hex: uint32): ColourU8 =
    [uint8(hex shr 24),
     uint8(hex shr 16),
     uint8(hex shr 8 ),
     uint8(hex shr 0 )]

func `$`*(c: ColourU8): string = &"0x{to_hex c.a}{to_hex c.b}{to_hex c.g}{to_hex c.r}"
func `$`*(c: ColourF32): string =
    let c = to_colouru8 c
    $c

func repr*(c: ColourU8): string  = &"ColourU8(r: {c.r}, g: {c.g}, b: {c.b}, a: {c.a})"
func repr*(c: ColourF32): string = &"ColourF32(r: {c.r:.2f}, g: {c.g:.2f}, b: {c.b:.2f}, a: {c.a:.2f})"

func `==`*(c1, c2: AColour): bool   = (c1.r == c2.r) and (c1.g == c2.g) and (c1.b == c2.b) and (c1.a == c2.a)
func `=~`*(c1, c2: ColourF32): bool = (c1.r =~ c2.r) and (c1.g =~ c2.g) and (c1.b =~ c2.b) and (c1.a =~ c2.a)

{.pop.}
