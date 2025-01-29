# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import std/options, common, util

type
    Vec2*  = array[2, float32]
    Vec3*  = array[3, float32]
    Vec4*  = array[4, float32]
    DVec2* = array[2, float]
    DVec3* = array[3, float]
    DVec4* = array[4, float]

    AVec*  = Vec2 | Vec3 | Vec4 | DVec2 | DVec3 | DVec4
    AVec2* = Vec2 | DVec2
    AVec3* = Vec3 | DVec3
    AVec4* = Vec4 | DVec4

const VectorFields = ["xyzw"]
type Swizzleable = AVec
include swizzle

const
    Vec2Zero*  = [float32 0, 0]
    Vec3Zero*  = [float32 0, 0, 0]
    Vec4Zero*  = [float32 0, 0, 0, 0]
    DVec2Zero* = [float 0, 0]
    DVec3Zero* = [float 0, 0, 0]
    DVec4Zero* = [float 0, 0, 0, 0]

{.push inline.}

converter dvec2_to_vec2*(v: DVec2): Vec2 = [float32 v.x, float32 v.y]
converter dvec3_to_vec3*(v: DVec3): Vec3 = [float32 v.x, float32 v.y, float32 v.z]
converter dvec4_to_vec4*(v: DVec4): Vec4 = [float32 v.x, float32 v.y, float32 v.z, float32 v.w]
converter vec2_to_dvec2*(v: Vec2): DVec2 = [float v.x, float v.y]
converter vec3_to_dvec3*(v: Vec3): DVec3 = [float v.x, float v.y, float v.z]
converter vec4_to_dvec4*(v: Vec4): DVec4 = [float v.x, float v.y, float v.z, float v.w]

func vec2*(x, y: float32 = 0): Vec2       = [x, y]
func vec3*(x, y, z: float32 = 0): Vec3    = [x, y, z]
func vec4*(x, y, z, w: float32 = 0): Vec4 = [x, y, z, w]
func dvec2*(x, y: float = 0): DVec2       = [x, y]
func dvec3*(x, y, z: float = 0): DVec3    = [x, y, z]
func dvec4*(x, y, z, w: float = 0): DVec4 = [x, y, z, w]

func vec4*(v: Vec3; w: float32 = 1): Vec4 = vec4 v.x, v.y, v.z, w
func vec3*(v: Vec2; z: float32 = 0): Vec4 = vec4 v.x, v.y, z

func vec*(x, y: float32): Vec2       = vec2 x, y
func vec*(x, y, z: float32): Vec3    = vec3 x, y, z
func vec*(x, y, z, w: float32): Vec4 = vec4 x, y, z, w
func dvec*(x, y: float): DVec2       = dvec2 x, y
func dvec*(x, y, z: float): DVec3    = dvec3 x, y, z
func dvec*(x, y, z, w: float): DVec4 = dvec4 x, y, z, w

func `$`*(v: AVec2): string = &"({v.x}, {v.y})"
func `$`*(v: AVec3): string = &"({v.x}, {v.y}, {v.z})"
func `$`*(v: AVec4): string = &"({v.x}, {v.y}, {v.z}, {v.w})"

func repr*(v: Vec2): string = &"Vec2 (x: {v.x}, y: {v.y})"
func repr*(v: Vec3): string = &"Vec3 (x: {v.x}, y: {v.y}, z: {v.z})"
func repr*(v: Vec4): string = &"Vec4 (x: {v.x}, y: {v.y}, z: {v.z}, w: {v.w})"
func repr*(v: DVec2): string = &"DVec2 (x: {v.x}, y: {v.y})"
func repr*(v: DVec3): string = &"DVec3 (x: {v.x}, y: {v.y}, z: {v.z})"
func repr*(v: DVec4): string = &"DVec4 (x: {v.x}, y: {v.y}, z: {v.z}, w: {v.w})"

#[ -------------------------------------------------------------------- ]#

func `==`*(v, u: AVec2): bool = (v.x == u.x) and (v.y == u.y)
func `==`*(v, u: AVec3): bool = (v.x == u.x) and (v.y == u.y) and (v.z == u.z)
func `==`*(v, u: AVec4): bool = (v.x == u.x) and (v.y == u.y) and (v.z == u.z) and (v.w == u.w)

func `=~`*(v, u: AVec2): bool = (v.x =~ u.x) and (v.y =~ u.y)
func `=~`*(v, u: AVec3): bool = (v.x =~ u.x) and (v.y =~ u.y) and (v.z =~ u.z)
func `=~`*(v, u: AVec4): bool = (v.x =~ u.x) and (v.y =~ u.y) and (v.z =~ u.z) and (v.w =~ u.w)

func clamped*(v: Vec2; min, max: SomeFloat): auto = [v.x.clamp(min, max), v.y.clamp(min, max)]
func clamped*(v: Vec3; min, max: SomeFloat): auto = [v.x.clamp(min, max), v.y.clamp(min, max), v.z.clamp(min, max)]
func clamped*(v: Vec4; min, max: SomeFloat): auto = [v.x.clamp(min, max), v.y.clamp(min, max), v.z.clamp(min, max), v.w.clamp(min, max)]
func clamped*[T: AVec2](v: T; min, max: T): T = [v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y)]
func clamped*[T: AVec3](v: T; min, max: T): T = [v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y), v.z.clamp(min.z, max.z)]
func clamped*[T: AVec4](v: T; min, max: T): T = [v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y), v.z.clamp(min.z, max.z), v.w.clamp(min.w, max.w)]

func clamp*[T: AVec](v: var T; min, max: SomeFloat) = v = v.clamped(min, max)
func clamp*[T: AVec](v: var T; min, max: T)         = v = v.clamped(min, max)

func `-`*[T: AVec2](v: T): T = [-v.x, -v.y]
func `-`*[T: AVec3](v: T): T = [-v.x, -v.y, -v.z]
func `-`*[T: AVec4](v: T): T = [-v.x, -v.y, -v.z, -v.w]

func `+`*[T: AVec2](v, u: T): T = [v.x + u.x, v.y + u.y]
func `+`*[T: AVec3](v, u: T): T = [v.x + u.x, v.y + u.y, v.z + u.z]
func `+`*[T: AVec4](v, u: T): T = [v.x + u.x, v.y + u.y, v.z + u.z, v.w + u.w]
func `+=`*[T: AVec](v: var T; u: T) = v = v + u

func `-`*[T: AVec2](v, u: T): T = [v.x - u.x, v.y - u.y]
func `-`*[T: AVec3](v, u: T): T = [v.x - u.x, v.y - u.y, v.z - u.z]
func `-`*[T: AVec4](v, u: T): T = [v.x - u.x, v.y - u.y, v.z - u.z, v.w - u.w]
func `-=`*[T: AVec](v: var T; u: T) = v = v - u

func `*`*[T: AVec2](v: T; s: SomeFloat): T = [s*v.x, s*v.y]
func `*`*[T: AVec3](v: T; s: SomeFloat): T = [s*v.x, s*v.y, s*v.z]
func `*`*[T: AVec4](v: T; s: SomeFloat): T = [s*v.x, s*v.y, s*v.z, s*v.w]
func `*`*[T: AVec2](s: SomeFloat; v: T): T = v*s
func `*`*[T: AVec3](s: SomeFloat; v: T): T = v*s
func `*`*[T: AVec4](s: SomeFloat; v: T): T = v*s
func `*`*[T: AVec2](v, u: T): T = [v.x*u.x, v.y*u.y]
func `*`*[T: AVec3](v, u: T): T = [v.x*u.x, v.y*u.y, v.z*u.z]
func `*`*[T: AVec4](v, u: T): T = [v.x*u.x, v.y*u.y, v.z*u.z, v.w*u.w]
func `*=`*[T: AVec](v: var T; s: SomeFloat) = v = s*v

func `/`*[T: AVec2](v: T; s: SomeFloat): T = [v.x/s, v.y/s]
func `/`*[T: AVec3](v: T; s: SomeFloat): T = [v.x/s, v.y/s, v.z/s]
func `/`*[T: AVec4](v: T; s: SomeFloat): T = [v.x/s, v.y/s, v.z/s, v.w/s]
func `/`*[T: AVec2](v, u: T): T = [v.x/u.x, v.y/u.y]
func `/`*[T: AVec3](v, u: T): T = [v.x/u.x, v.y/u.y, v.z/u.z]
func `/`*[T: AVec4](v, u: T): T = [v.x/u.x, v.y/u.y, v.z/u.z, v.w/u.w]
func `/=`*[T: AVec](v: var T; s: SomeFloat) = v = v/s

func dot*[T: AVec2](v, u: T): auto = v.x*u.x + v.y*u.y
func dot*[T: AVec3](v, u: T): auto = v.x*u.x + v.y*u.y + v.z*u.z
func dot*[T: AVec4](v, u: T): auto = v.x*u.x + v.y*u.y + v.z*u.z + v.w*u.w
func `∙`*(v, u: AVec): auto =
    ## `\\bullet`
    dot v, u

func norm2*[T: AVec](v: T): auto = v∙v
func norm*[T: AVec](v: T): auto  = sqrt(norm2 v)
func mag*(v: AVec): auto         = norm v

func normalized*[T: AVec](v: T): T =
    let mag = mag v
    if mag != 0:
        result = v / mag
    else:
        result = zero_default T
func normalize*(v: var AVec) = v = normalized v

func distance2*(v, u: AVec2): auto = (v.x - u.x)^2 + (v.y - u.y)^2
func distance2*(v, u: AVec3): auto = (v.x - u.x)^2 + (v.y - u.y)^2 + (v.z - u.z)^2
func distance*(v, u: AVec2 | AVec3): auto = sqrt distance2(v, u)
func dist2*(v, u: AVec2 | AVec3): auto = distance2 v, u
func dist*(v, u: AVec2 | AVec3): auto  = distance  v, u

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
    ## Axis should already be normalized
    ngm_assert (axis.mag =~ 1.0), "Axis should be normalized before rotation"

    let cosa = cos α
    let sina = sin α
    v*cosa + (axis × v)*sina + axis*(axis ∙ v)*(1 - cosa)

func rotate*(v: var AVec2; α: Radians)                = v = rotated(v, α)
func rotate*[T: AVec3](v: var T; α: Radians; axis: T) = v = rotated(v, α, axis)

func reflected*[T: AVec2 | AVec3](v, n: T): T   = v - 2*(v∙n)*n
func reflect*[T: AVec2 | AVec3](v: var T; n: T) = v = reflected(v, n)

func refracted*[T: AVec2 | AVec3](v, n: T; μ: SomeFloat): Option[T] =
    ## Normal should already be normlized
    ngm_assert (n.mag =~ 1), "Normal should be normalized before refraction"

    let dp = n∙v
    let k  = 1 - (μ^2)*(1 - dp^2)
    if k < 0:
        return none[T]
    some (sqrt(k)*n + μ*(v - dp*n))

func refract*[T: AVec2 | AVec3](v: var T; n: T; μ: SomeFloat): bool =
    let r = refracted(v, n, μ)
    result = r.is_some
    v = if result: get r else: default v

func centre*[T: AVec2 | AVec3](p1, p2: T): T = (p1 + p2)/2

{.pop.}
