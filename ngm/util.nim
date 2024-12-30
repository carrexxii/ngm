import std/math, common, borrows
from std/strutils import parse_float

type
    Degrees* = distinct Real
    Radians* = distinct Real

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

func sin*(α: Radians): Real = sin Real α
func cos*(α: Radians): Real = cos Real α
func tan*(α: Radians): Real = tan Real α

{.pop.}
