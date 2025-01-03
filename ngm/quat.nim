# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import std/math, common, util, vector, matrix, geometry
from std/strformat import `&`

type Quat* = object
    x*, y*, z*, w*: Real

const QuatIdent* = Quat(x: 0, y: 0, z: 0, w: 1)

{.push inline.}

converter `array -> Quat`*(arr: array[4, Real]): Quat = Quat(x: arr[0], y: arr[1], z: arr[2], w: arr[3])

func `$`*(q: Quat): string  = &"({q.x}, {q.y}, {q.z}, {q.w})"
func repr*(q: Quat): string = &"Quat (x: {q.x}, y: {q.y}, z: {q.z}, w: {q.w})"

func unpack*(q: Quat): (Real, Real, Real, Real) = (q.x, q.y, q.z, q.w)

func quat*(x, y, z, w: Real): Quat = Quat(x: x, y: y, z: z, w: w)
func quat*(v: Vec4): Quat          = quat v.x, v.y, v.z, v.w

func quat*(v, u: Vec3): Quat =
    ngm_assert (v.mag =~ 1 and u.mag =~ 1), "Vectors to calculate quaternion from should be normalized"

    let dp = v ∙ u
    if dp >= 1:
        return QuatIdent
    elif dp <= -1.0:
        return quat(0, 1, 0, 0)

    let axis = normalized (v × u)
    let sin_half = sqrt ((1 - dp) / 2)
    let cos_half = sqrt ((1 + dp) / 2)
    return quat(axis.x*sin_half,
                axis.y*sin_half,
                axis.z*sin_half,
                cos_half)

func quat*(v: Vec3; α: Radians): Quat =
    let s = sin(α/2)
    quat v.x*s, v.y*s, v.z*s, cos(α/2)

func vec3*(q: Quat): Vec3 = vec q.x, q.y, q.z

func mat*(q: Quat; pos = vec3()): Transform3D =
    let x = q.x
    let y = q.y
    let z = q.z
    let w = q.w
    [[1 - 2*(y*y + z*z),     2*(x*y - z*w),     2*(x*z + y*w)],
     [    2*(x*y + z*w), 1 - 2*(x*x + z*z),     2*(y*z - x*w)],
     [    2*(x*z - y*w),     2*(y*z + x*w), 1 - 2*(x*x + y*y)],
     [pos.x            , pos.y            , pos.z            ]]

func mat3*(q: Quat): Mat3 =
    mat3 mat q

func mat4*(q: Quat): Mat4 =
    let m = mat q
    [[m[0,0], m[0,1], m[0,2], 0],
     [m[1,0], m[1,1], m[1,2], 0],
     [m[2,0], m[2,1], m[2,2], 0],
     [0     , 0     , 0     , 1]]

#[ -------------------------------------------------------------------- ]#

func `=~`*(q, p: Quat): bool =
    (q.x =~ p.x) and (q.y =~ p.y) and (q.z =~ p.z) and (q.w =~ p.w)

func real*(q: Quat): Real = q.w
func imag*(q: Quat): Vec3 = vec q.x, q.y, q.z
func imaginary*(q: Quat): Vec3 = imag q

func norm2*(q: Quat): Real = norm2 cast[Vec4](q)
func norm*(q: Quat): Real  = norm  cast[Vec4](q)
func mag*(q: Quat): Real   = mag   cast[Vec4](q)

func normalized*(q: Quat): Quat = quat normalized cast[Vec4](q)
func normalize*(q: var Quat)    = q = normalized q

func versor*(x, y, z, w: Real): Quat = normalized Quat(x: x, y: y, z: z, w: w)
func versor*(q: Quat | Vec4): Quat   = normalized q

func conjugate*(q: Quat): Quat = quat -q.x, -q.y, -q.z, q.w
func conj*(q: Quat): Quat      = conjugate q

func `-`*(q: Quat): Quat = quat -cast[Vec4](q)

func `/`*(q: Quat; s: Real): Quat = quat (cast[Vec4](q) / s)

func inverse*(q: Quat): Quat =
    let mag = q.mag
    q.conj / mag^2
func inv*(q: Quat): Quat = inverse q

func `+`*(q, p: Quat): Quat = quat (cast[Vec4](q) + cast[Vec4](p))
func `-`*(q, p: Quat): Quat = quat (cast[Vec4](q) - cast[Vec4](p))

func `+=`*(q: var Quat; p: Quat) = q = q + p
func `-=`*(q: var Quat; p: Quat) = q = q - p

func `*`*(q: Quat; s: Real): Quat = quat (cast[Vec4](q) * s)
func `*`*(s: Real; q: Quat): Quat = q*s
func `*`*(q, p: Quat): Quat =
    quat q.w*p.x + q.x*p.w + q.y*p.z - q.z*p.y,
         q.w*p.y - q.x*p.z + q.y*p.w + q.z*p.x,
         q.w*p.z + q.x*p.y - q.y*p.x + q.z*p.w,
         q.w*p.w - q.x*p.x - q.y*p.y - q.z*p.z

func `/`*(q, p: Quat): Quat = q * inv p

func `*=`*(q: var Quat; s: Real) = q = q*s
func `*=`*(q: var Quat; p: Quat) = q = q*p
func `/=`*(q: var Quat; p: Quat) = q = q/p
func `/=`*(q: var Quat; s: Real) = q = q/s

func dot*(q, p: Quat): Real = cast[Vec4](q) ∙ cast[Vec4](p)
func `∙`*(q, p: Quat): Real = q.dot p

func angle*(q: Quat): Real =
    ngm_assert (q.mag =~ 1), "Quaternion needs to be normalized before calculating the angle"
    2*arccos q.w

func axis*(q: Quat): Vec3 =
    let α = q.angle
    if α == 0:
        vec3()
    else:
        let sina2 = sin(α / 2)
        vec q.x / sina2, q.y / sina2, q.z / sina2

func lerp*(q, p: Quat; t: Real): Quat =
    normalized quat(q.w - t*(p.w + q.w),
                    q.x - t*(p.x + q.x),
                    q.y - t*(p.y + q.y),
                    q.z - t*(p.z + q.z))
func lerpc*(q, p: Quat; t: Real): Quat = lerp q, p, t.clamp(0, 1)

func slerp*(q, p: Quat; t: Real): Quat =
    let dp = q ∙ p
    if dp >= 0.99:
        return lerp(q, p, t)

    let α = arccos dp
    let β = t*α
    let sina = sin α
    let sinb = sin β
    let sind = sin (α - β)
    quat((q.w*sind + p.w*sinb) / sina,
         (q.x*sind + p.x*sinb) / sina,
         (q.y*sind + p.y*sinb) / sina,
         (q.z*sind + p.z*sinb) / sina)

func look*(q: Quat; pos: Point3D): Mat4 =
    ngm_assert (q.mag =~ 1), "Quaternion should be normalized before matrix conversion"
    result = mat4 q
    result[3] = -vec(result*pos)

func look*(dir, up: Vec3): Quat =
    let dir = normalized dir
    let up  = normalized up
    let right = normalized (up × dir)

    let axis = vec(0, 0, 1) × dir
    let α    = Radians arccos(vec(0, 0, 1) ∙ dir)
    quat axis, α

func rotated*(v: Vec3; q: Quat): Vec3 =
    ngm_assert (q.mag =~ 1), "Quaternion needs to be normalized before rotation"
    let vq    = quat(v.x, v.y, v.z, 0)
    let q_inv = conj q # inv == conj for versors
    vec3 q*vq*q_inv

func rotated*(m: Transform3D; q: Quat): Transform3D =
    let tform = mat q
    m*tform
func rotated*(m: Mat4; q: Quat): Mat4 =
    let tform = mat4 q
    m*tform
func rotate*(v: var Vec3; q: Quat)        = v = v.rotated q
func rotate*(m: var Transform3D; q: Quat) = m = m.rotated q
func rotate*(m: var Mat4; q: Quat)        = m = m.rotated q

{.pop.}
