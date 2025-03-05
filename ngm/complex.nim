# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import common, util, vector
from std/strutils import parse_float

type
    ComplexNumber*[T] = object
        a*, b*: T

    Complex32* = ComplexNumber[float32]
    Complex64* = ComplexNumber[float]

    C[T] = ComplexNumber[T]

when defined Ngm64:
    type Complex* = Complex64
    func complex*(a, b: float): Complex = Complex(a: a, b: b)
else:
    type Complex* = Complex32
    func complex*(a, b: float32): Complex = Complex(a: a, b: b)

proc `'i`*(z: string): Complex {.compileTime.} = Complex(b: parse_float z)

func `$`*[T](z: ComplexNumber[T]): string =
    if z.a != 0 and z.b != 0:
        let sgn = if z.b < 0: '-' else: '+'
        &"{z.a} {sgn} {abs z.b}i"
    elif z.a == 0:
        &"{z.b}i"
    elif z.b == 0:
        &"{z.a}"
    else:
        "0.0"

func repr*[T](x: C[T]): string = &"Complex({x.a}, {x.b}i)"

{.push inline.}

func complex32*(a, b: SomeNumber): Complex32 = Complex32(a: float32 a, b: float32 b)
func complex64*(a, b: SomeNumber): Complex64 = Complex64(a: float   a, b: float   b)
func complex*(v: Vec2): Complex32  = Complex32(a: v.x, b: v.y)
func complex*(v: DVec2): Complex64 = Complex64(a: v.x, b: v.y)
func vec*(z: Complex32): Vec2  =  vec z.a, z.b
func vec*(z: Complex64): DVec2 = dvec z.a, z.b

func complex32*(α: Radians): Complex32 = Complex32(a: cos α, b: sin α)
func complex64*(α: Radians): Complex64 = Complex64(a: cos α, b: sin α)

func `==`*[T](z, w: C[T]): bool = (z.a == w.a) and (z.b == w.b)
func `=~`*[T](z, w: C[T]): bool = (z.a =~ w.a) and (z.b =~ w.b)

func abs2*[T](z: C[T]): T  = z.a^2 + z.b^2
func abs*[T](z: C[T]): T   = sqrt abs2 z
func norm2*[T](z: C[T]): T = abs2 z
func norm*[T](z: C[T]): T  = abs z
func mag2*[T](z: C[T]): T  = abs2 z
func mag*[T](z: C[T]): T   = abs z

func arg*[T](z: C[T]): Radians =
    atan2(z.b, z.a)

# func sgn*[T](z: Complex[T]): Complex[T] =
#   ## Returns the phase of `z` as a unit complex number,
#   ## or 0 if `z` is 0.
#   let a = abs(z)
#   if a != 0:
#     result = z / a
func sign*[T](z: C[T]): C[T] =
    let m = abs z
    if m != 0:
        result = z/m
func sgn*[T](z: C[T]): C[T] = sign z

func conjugate*[T](z: C[T]): C[T] = C[T](a: z.a, b: -z.b)
func conj*[T](z: C[T]): C[T]      = conjugate z

func inverse*[T](z: C[T]): C[T] = (conj z) / (abs2 z)
func inv*[T](z: C[T]): C[T]     = inverse z

func `-`*[T](z: C[T]): C[T] = C[T](a: -z.a, b: -z.b)
func `+`*[T](z: C[T]): C[T] = C[T](a:  z.a, b:  z.b)

func `+`*[T](z, w: C[T]): C[T]             = C[T](a: z.a + w.a, b: z.b + w.b)
func `+`*[T](z: C[T]; s: SomeNumber): C[T] = C[T](a: z.a + T s, b: z.b)
func `+`*[T](s: SomeNumber; z: C[T]): C[T] = z + s
func `+=`*[T](z: var C[T]; w: C[T]) = z = z + w
func `+=`*[T](z: var C[T]; s: T)    = z = z + s

func `-`*[T](z, w: C[T]): C[T]             = C[T](a: z.a - w.a, b: z.b - w.b)
func `-`*[T](z: C[T]; s: SomeNumber): C[T] = C[T](a: z.a - T s, b: z.b)
func `-`*[T](s: SomeNumber; z: C[T]): C[T] = -z + s
func `-=`*[T](z: var C[T]; w: C[T]) = z = z - w
func `-=`*[T](z: var C[T]; s: T)    = z = z - s

func `*`*[T](z, w: C[T]): C[T]             = C[T](a: z.a*w.a - w.b*z.b, b: z.a*w.b + z.b*w.a)
func `*`*[T](z: C[T]; s: SomeNumber): C[T] = C[T](a: z.a*T s, b: z.b*T s)
func `*`*[T](s: SomeNumber; z: C[T]): C[T] = z*s
func `*=`*[T](z: var C[T]; w: C[T]) = z = z*w
func `*=`*[T](z: var C[T]; s: T)    = z = z*s

func `/`*[T](z, w: C[T]): C[T]             = z*inv w
func `/`*[T](z: C[T]; s: SomeNumber): C[T] = C[T](a: z.a/T s, b: z.b/T s)
func `/`*[T](s: SomeNumber; z: C[T]): C[T] = s*inv z
func `/=`*[T](z: var C[T]; w: C[T]) = z = z/w
func `/=`*[T](z: var C[T]; s: T)    = z = z/s

func normalise*[T](z: var C[T]) = z /= z.mag
func normalised*[T](z: C[T]): C[T] =
    result = z
    normalise result

{.pop.}
