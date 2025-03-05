# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import common, util, vector
from std/strutils import parse_float

type
    AComplex*[T] = object
        ## `a + bi`
        a*, b*: T

    Complex32* = AComplex[float32]
    Complex64* = AComplex[float64]

    Complex* = Complex32

    C[T] = AComplex[T]

proc `'i`*(z: string): Complex {.compileTime.} = Complex(b: parse_float z)

func `$`*[T](z: AComplex[T]): string =
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

#[ -------------------------------------------------------------------- ]#

{.push inline.}

func complex32*(a, b: SomeNumber): Complex32 = Complex32(a: float32 a, b: float32 b)
func complex64*(a, b: SomeNumber): Complex64 = Complex64(a: float64 a, b: float64 b)
func complex*(a, b: SomeNumber): Complex     = Complex(a: float32 a, b: float32 b)
func complex*(v: AVec2[float64]): Complex64  = Complex64(a: float64 v.x, b: float64 v.y)
func complex*[T](v: AVec2[T]): Complex       = Complex(a: float32 v.x, b: float32 v.y)

func vec*(z: Complex32): Vec2    = [z.a, z.b]
func vec*(z: Complex64): Vec2F64 = [z.a, z.b]

func complex32*(α: Radians): Complex32 = Complex32(a: cos α, b: sin α)
func complex64*(α: Radians): Complex64 = Complex64(a: cos α, b: sin α)
func complex*(α: Radians): Complex     = complex32 α

func `==`*[T](z, w: C[T]): bool = (z.a == w.a) and (z.b == w.b)
func `=~`*[T](z, w: C[T]): bool = (z.a =~ w.a) and (z.b =~ w.b)

func abs2*[T](z: C[T]): T  = z.a^2 + z.b^2
func norm2*[T](z: C[T]): T = abs2 z
func mag2*[T](z: C[T]): T  = abs2 z

func abs*[T](z: C[T]): T  = sqrt abs2 z
func norm*[T](z: C[T]): T = abs z
func mag*[T](z: C[T]): T  = abs z

func arg*[T](z: C[T]): Radians =
    atan2 z.b, z.a

func conjugate*[T](z: C[T]): C[T] = C[T](a: z.a, b: -z.b)
func conj*[T](z: C[T]): C[T]      = conjugate z

func inverse*[T](z: C[T]): C[T] = z.conj / z.abs2
func inv*[T](z: C[T]): C[T]     = inverse z

func `-`*[T](z: C[T]): C[T] = C[T](a: -z.a, b: -z.b)

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
func `*`*[T](s: SomeNumber; z: C[T]): C[T] = z * s
func `*=`*[T](z: var C[T]; w: C[T]) = z = z * w
func `*=`*[T](z: var C[T]; s: T)    = z = z * s

func `/`*[T](z, w: C[T]): C[T]             = z * inv w
func `/`*[T](z: C[T]; s: SomeNumber): C[T] = C[T](a: z.a/T s, b: z.b/T s)
func `/`*[T](s: SomeNumber; z: C[T]): C[T] = s * inv z
func `/=`*[T](z: var C[T]; w: C[T]) = z = z / w
func `/=`*[T](z: var C[T]; s: T)    = z = z / s

func normalise*[T](z: var C[T]) = z /= z.mag
func normalised*[T](z: C[T]): C[T] =
    result = z
    normalise result

{.pop.}
