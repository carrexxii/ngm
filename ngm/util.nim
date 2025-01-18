# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import std/math, common, borrows
from std/strutils import parse_float
export sqrt, pow, `^`

type
    Degrees* = distinct float
    Radians* = distinct float

const π*   = Radians Pi
const π⋅2* = Radians Pi*2
const π÷2* = Radians Pi/2

proc `'deg`*(x: string): Degrees {.compileTime.} = Degrees parse_float x
proc `'°`*(x: string): Degrees   {.compileTime.} = Degrees parse_float x
proc `'rad`*(x: string): Radians {.compileTime.} = Radians parse_float x

borrow_unit Degrees
borrow_unit Radians

{.push inline.}

converter `Degrees -> Radians`*(a: Degrees): Radians = Radians a*(Pi / 180)
converter `Radians -> Degrees`*(a: Radians): Degrees = Degrees a*(180 / Pi)

func `=~`*(a, b: Degrees): bool {.borrow.}
func `=~`*(a, b: Radians): bool {.borrow.}

func radians*(a: SomeNumber): Radians = Radians a
func degrees*(a: SomeNumber): Degrees = Degrees a
func rad*(a: SomeNumber): Radians = radians a
func deg*(a: SomeNumber): Degrees = degrees a

func radians*(a: Degrees): Radians = `Degrees -> Radians` a
func degrees*(a: Radians): Degrees = `Radians -> Degrees` a
func rad*(a: Degrees): Radians = radians a
func deg*(a: Radians): Degrees = degrees a

func sin*(α: Radians): float = sin float α
func cos*(α: Radians): float = cos float α
func tan*(α: Radians): float = tan float α
func csc*(α: Radians): float = csc float α
func sec*(α: Radians): float = sec float α
func cot*(α: Radians): float = cot float α

func asin*(x: SomeFloat): Radians     = Radians arcsin x
func acos*(x: SomeFloat): Radians     = Radians arccos x
func atan*(x: SomeFloat): Radians     = Radians arctan x
func atan2*(x, y: SomeFloat): Radians = Radians arctan2(x, y)

#[ -------------------------------------------------------------------- ]#

func sign*(x: SomeNumber): int32 =
    if x > 0: 1 elif x < 0: -1 else: 0

{.pop.}
