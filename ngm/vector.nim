# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import std/options, common, util

type
    AVec2*[T] = array[2, T]
    AVec3*[T] = array[3, T]
    AVec4*[T] = array[4, T]

    Vec2F32* = AVec2[float32]
    Vec2F64* = AVec2[float64]
    Vec2I8*  = AVec2[int8]
    Vec2I16* = AVec2[int16]
    Vec2I32* = AVec2[int32]
    Vec2I64* = AVec2[int64]
    Vec2U8*  = AVec2[uint8]
    Vec2U16* = AVec2[uint16]
    Vec2U32* = AVec2[uint32]
    Vec2U64* = AVec2[uint64]

    Vec3F32* = AVec3[float32]
    Vec3F64* = AVec3[float64]
    Vec3I8*  = AVec3[int8]
    Vec3I16* = AVec3[int16]
    Vec3I32* = AVec3[int32]
    Vec3I64* = AVec3[int64]
    Vec3U8*  = AVec3[uint8]
    Vec3U16* = AVec3[uint16]
    Vec3U32* = AVec3[uint32]
    Vec3U64* = AVec3[uint64]

    Vec4F32* = AVec4[float32]
    Vec4F64* = AVec4[float64]
    Vec4I8*  = AVec4[int8]
    Vec4I16* = AVec4[int16]
    Vec4I32* = AVec4[int32]
    Vec4I64* = AVec4[int64]
    Vec4U8*  = AVec4[uint8]
    Vec4U16* = AVec4[uint16]
    Vec4U32* = AVec4[uint32]
    Vec4U64* = AVec4[uint64]

    Vec2* = Vec2F32
    Vec3* = Vec3F32
    Vec4* = Vec4F32

    AVec*[T] = AVec2[T] | AVec3[T] | AVec4[T]

converter vec2_to_arr*[T](v: AVec2[T]): array[2, T] = v
converter vec3_to_arr*[T](v: AVec3[T]): array[3, T] = v
converter vec4_to_arr*[T](v: AVec4[T]): array[4, T] = v

const VectorFields = ["xyzw"]
type Swizzleable = AVec
include swizzle

func `$`*(v: AVec2): string = &"({v.x}, {v.y})"
func `$`*(v: AVec3): string = &"({v.x}, {v.y}, {v.z})"
func `$`*(v: AVec4): string = &"({v.x}, {v.y}, {v.z}, {v.w})"

#[ -------------------------------------------------------------------- ]#

template bc(v: AVec; fn: untyped): untyped =
    when v is AVec2:
        [fn v.x, fn v.y]
    elif v is AVec3:
        [fn v.x, fn v.y, fn v.z]
    elif v is AVec4:
        [fn v.x, fn v.y, fn v.z, fn v.w]
    else:
        do_assert false, "Invalid type for `bc`"

template bc2(v, u: AVec; fn: untyped): untyped =
    when v is AVec2:
        [fn(v.x, u.x), fn(v.y, u.y)]
    elif v is AVec3:
        [fn(v.x, u.x), fn(v.y, u.y), fn(v.z, u.z)]
    elif v is AVec4:
        [fn(v.x, u.x), fn(v.y, u.y), fn(v.z, u.z), fn(v.w, u.w)]
    else:
        do_assert false, "Invalid type for `bc2`"

{.push inline.}

{.push warning[ImplicitDefaultValue]: off.}
func vec2*[T](x, y: distinct SomeNumber = 0): AVec2[T]       = [T x, T y]
func vec3*[T](x, y, z: distinct SomeNumber = 0): AVec3[T]    = [T x, T y, T z]
func vec4*[T](x, y, z, w: distinct SomeNumber = 0): AVec4[T] = [T x, T y, T z, T w]
{.pop.}

func vec4*[T](v: AVec3; w: SomeNumber = 1): AVec4[T]                    = [T v.x, T v.y, T v.z, T w]
func vec4*[T](v: AVec2; z: SomeNumber = 0; w: SomeNumber = 1): AVec4[T] = [T v.x, T v.y, T z, T w]

func vec3*[T](v: AVec2; z = T 0): AVec3[T] = [T v.x, T v.y, z]
func vec3*[T](v: AVec4): AVec3[T] =
    ## This truncates and does not divide by `w`
    [T v.x, T v.y, T v.z]

func vec*(x, y: distinct SomeNumber): Vec2       = [float32 x, float32 y]
func vec*(x, y, z: distinct SomeNumber): Vec3    = [float32 x, float32 y, float32 z]
func vec*(x, y, z, w: distinct SomeNumber): Vec4 = [float32 x, float32 y, float32 z, float32 w]

func vec_to*[T](v: AVec2): AVec2[T] = [T v.x, T v.y]
func vec_to*[T](v: AVec3): AVec3[T] = [T v.x, T v.y, T v.z]
func vec_to*[T](v: AVec4): AVec4[T] = [T v.x, T v.y, T v.z, T v.w]

func `==`*[T](v, u: AVec2[T]): bool = (v.x == u.x) and (v.y == u.y)
func `==`*[T](v, u: AVec3[T]): bool = (v.x == u.x) and (v.y == u.y) and (v.z == u.z)
func `==`*[T](v, u: AVec4[T]): bool = (v.x == u.x) and (v.y == u.y) and (v.z == u.z) and (v.w == u.w)

func `=~`*[T](v, u: AVec2[T]): bool = (v.x =~ u.x) and (v.y =~ u.y)
func `=~`*[T](v, u: AVec3[T]): bool = (v.x =~ u.x) and (v.y =~ u.y) and (v.z =~ u.z)
func `=~`*[T](v, u: AVec4[T]): bool = (v.x =~ u.x) and (v.y =~ u.y) and (v.z =~ u.z) and (v.w =~ u.w)

func clamp*[T](v: AVec2[T]; min, max: SomeNumber): AVec2[T] = [v.x.clamp(T min, T max), v.y.clamp(T min, T max)]
func clamp*[T](v: AVec3[T]; min, max: SomeNumber): AVec3[T] = [v.x.clamp(T min, T max), v.y.clamp(T min, T max), v.z.clamp(T min, T max)]
func clamp*[T](v: AVec4[T]; min, max: SomeNumber): AVec4[T] = [v.x.clamp(T min, T max), v.y.clamp(T min, T max), v.z.clamp(T min, T max), v.w.clamp(T min, T max)]
func clamp*[T](v: AVec2[T]; min, max: AVec2[T]): AVec2[T] = [v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y)]
func clamp*[T](v: AVec3[T]; min, max: AVec3[T]): AVec3[T] = [v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y), v.z.clamp(min.z, max.z)]
func clamp*[T](v: AVec4[T]; min, max: AVec4[T]): AVec4[T] = [v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y), v.z.clamp(min.z, max.z), v.w.clamp(min.w, max.w)]

func trunc*[T](v: AVec2[T]): AVec2[T] = v.bc trunc
func trunc*[T](v: AVec3[T]): AVec3[T] = v.bc trunc
func trunc*[T](v: AVec4[T]): AVec4[T] = v.bc trunc

func round*[T](v: AVec2[T]): AVec2[T] = v.bc round
func round*[T](v: AVec3[T]): AVec3[T] = v.bc round
func round*[T](v: AVec4[T]): AVec4[T] = v.bc round

func `-`*[T](v: AVec2[T]): AVec2[T] = v.bc `-`
func `-`*[T](v: AVec3[T]): AVec3[T] = v.bc `-`
func `-`*[T](v: AVec4[T]): AVec4[T] = v.bc `-`

func `+`*[T](v, u: AVec2[T]): AVec2[T] = bc2 v, u, `+`
func `+`*[T](v, u: AVec3[T]): AVec3[T] = bc2 v, u, `+`
func `+`*[T](v, u: AVec4[T]): AVec4[T] = bc2 v, u, `+`
func `+=`*[T: AVec](v: var T; u: T) = v = v + u

func `-`*[T](v, u: AVec2[T]): AVec2[T] = bc2 v, u, `-`
func `-`*[T](v, u: AVec3[T]): AVec3[T] = bc2 v, u, `-`
func `-`*[T](v, u: AVec4[T]): AVec4[T] = bc2 v, u, `-`
func `-=`*[T: AVec](v: var T; u: T) = v = v - u

func `*`*[T](v: AVec2[T]; s: SomeNumber): AVec2[T] = [v.x*T s, v.y*T s]
func `*`*[T](v: AVec3[T]; s: SomeNumber): AVec3[T] = [v.x*T s, v.y*T s, v.z*T s]
func `*`*[T](v: AVec4[T]; s: SomeNumber): AVec4[T] = [v.x*T s, v.y*T s, v.z*T s, v.w*T s]
func `*`*[T](s: SomeNumber; v: AVec2[T]): AVec2[T] = v * s
func `*`*[T](s: SomeNumber; v: AVec3[T]): AVec3[T] = v * s
func `*`*[T](s: SomeNumber; v: AVec4[T]): AVec4[T] = v * s
func `*`*[T](v, u: AVec2[T]): AVec2[T] = bc2 v, u, `*`
func `*`*[T](v, u: AVec3[T]): AVec3[T] = bc2 v, u, `*`
func `*`*[T](v, u: AVec4[T]): AVec4[T] = bc2 v, u, `*`
func `*=`*(v: var AVec; s: SomeNumber) = v = s * v

func `/`*[T](v: AVec2[T]; s: SomeNumber): AVec2[T] = [v.x/s, v.y/s]
func `/`*[T](v: AVec3[T]; s: SomeNumber): AVec3[T] = [v.x/s, v.y/s, v.z/s]
func `/`*[T](v: AVec4[T]; s: SomeNumber): AVec4[T] = [v.x/s, v.y/s, v.z/s, v.w/s]
func `/`*[T](v, u: AVec2[T]): AVec2[T] = [v.x/u.x, v.y/u.y]
func `/`*[T](v, u: AVec3[T]): AVec3[T] = [v.x/u.x, v.y/u.y, v.z/u.z]
func `/`*[T](v, u: AVec4[T]): AVec4[T] = [v.x/u.x, v.y/u.y, v.z/u.z, v.w/u.w]
func `/=`*[T: AVec](v: var T; s: SomeNumber) = v = v / s

func dot*[T](v, u: AVec2[T]): T = v.x*u.x + v.y*u.y
func dot*[T](v, u: AVec3[T]): T = v.x*u.x + v.y*u.y + v.z*u.z
func dot*[T](v, u: AVec4[T]): T = v.x*u.x + v.y*u.y + v.z*u.z + v.w*u.w
func `∙`*(v, u: AVec): auto =
    ## `\\bullet`
    dot v, u

func norm2*(v: AVec): auto = v∙v
func mag2*(v: AVec): auto  = norm2 v

func norm*(v: AVec): auto = sqrt(norm2 v)
func mag*(v: AVec): auto  = norm v

func normalized*[T: AVec](v: T): T =
    let mag = mag v
    if mag != 0:
        v / mag
    else:
        default T
func normalize*(v: var AVec) = v = normalized v

func distance2*[T](p1, p2: AVec2[T]): T = (p1.x - p2.x)^2 + (p1.y - p2.y)^2
func distance2*[T](p1, p2: AVec3[T]): T = (p1.x - p2.x)^2 + (p1.y - p2.y)^2 + (p1.z - p2.z)^2
func dist2*[T](p1, p2: AVec2[T] | AVec3[T]): T = distance2 p1, p2

func distance*[T](p1, p2: AVec2[T] | AVec3[T]): T = sqrt distance2(p1, p2)
func dist*[T](p1, p2: AVec2[T] | AVec3[T]): T = distance p1, p2

func angle*(v, u: AVec2 | AVec3): Radians =
    acos((v ∙ u) / (v.mag * u.mag))

func cross*[T: AVec3](v, u: T): T =
    [v.y*u.z - v.z*u.y,
     v.z*u.x - v.x*u.z,
     v.x*u.y - v.y*u.x]
func `×`*[T: AVec3](v, u: T): T = cross v, u

func rotated*[T: AVec2](v: T; α: Radians): T =
    ## Rotates CCW
    let cosa = cos α
    let sina = sin α
    [cosa*v.x - sina*v.y, sina*v.x + cosa*v.y]

func rotated*[T: AVec3](v: T; α: Radians; axis: T): T =
    ## Rodrigues' rotation formula
    ## `v = v*cos(α) + (k×v)sin(α) + k*(k∙v)(1 - cos(α))`
    ## where `k` is the axis of rotation
    ## Axis should already be normalised
    ngm_assert (axis.mag =~ 1.0), "Axis should be normalised before rotation"

    let cosa = cos α
    let sina = sin α
    v*cosa + (axis × v)*sina + axis*(axis ∙ v)*(1 - cosa)

func rotate*(v: var AVec2; α: Radians)                = v = rotated(v, α)
func rotate*[T: AVec3](v: var T; α: Radians; axis: T) = v = rotated(v, α, axis)

func reflected*[T: AVec2 | AVec3](v, n: T): T   = v - 2*(v∙n)*n
func reflect*[T: AVec2 | AVec3](v: var T; n: T) = v = reflected(v, n)

func refracted*[T: AVec2 | AVec3](v, n: T; μ: SomeNumber): Option[T] =
    ## Normal should already be normalised
    ngm_assert (n.mag =~ 1), "Normal should be normalised before refraction"

    let dp = n∙v
    let k  = 1 - (μ*μ)*(1 - dp*dp)
    if k < 0:
        none[T]
    else:
        some (sqrt(k)*n + μ*(v - dp*n))

func refract*[T: AVec2 | AVec3](v: var T; n: T; μ: SomeNumber): bool =
    let r = refracted(v, n, μ)
    result = r.is_some
    v = if result: get r else: default v

func centre*[T: AVec2 | AVec3](p1, p2: T): T = 0.5*(p1 + p2)

{.pop.}
