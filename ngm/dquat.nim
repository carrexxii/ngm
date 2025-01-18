# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import std/math, common, util, vector, quat, matrix

type DQuat* = object
    real*: Quat
    dual*: Quat

const DQuatIdent* = DQuat(real: quat(0'f32, 0, 0, 1),
                          dual: quat(0'f32, 0, 0, 0))

{.push inline.}

converter quat_array_to_dquat*(arr: array[2, Quat]): DQuat = DQuat(real: arr[0], dual: arr[1])

func `$`*(q: DQuat): string  = &"[{q.real}; {q.dual}]"
func repr*(q: DQuat): string = &"DQuat [real: {repr q.real}; dual: {repr q.dual}]"

func `==`*(q, p: DQuat): bool = (q.real == p.real) and (q.dual == p.dual)
func `=~`*(q, p: DQuat): bool = (q.real =~ p.real) and (q.dual =~ p.dual)

func `-`*(q: DQuat): DQuat = [-q.real, -q.dual]

func `+`*(q, p: DQuat): DQuat = [q.real + p.real, q.dual + p.dual]
func `-`*(q, p: DQuat): DQuat = [q.real - p.real, q.dual - p.dual]

func `+=`*(q: var DQuat; p: DQuat) = q = q + p
func `-=`*(q: var DQuat; p: DQuat) = q = q - p

func `*`*(q, p: DQuat): DQuat          = [q.real*p.real, q.real*p.dual + q.dual*p.real]
func `*`*(q: DQuat; s: float32): DQuat = [s*q.real, s*q.dual]
func `*`*(s: float32; q: DQuat): DQuat = q*s
func `/`*(q: DQuat; s: float32): DQuat = [q.real/s, q.dual/s]

func `*=`*(q: var DQuat; p: DQuat)   = q = q*p
func `*=`*(q: var DQuat; s: float32) = q = q*s
func `/=`*(q: var DQuat; s: float32) = q = q/s

func dot*(q, p: DQuat): float32 = q.real ∙ p.real
func `∙`*(q, p: DQuat): float32 = q.real ∙ p.real

func conjugate*(q: DQuat): DQuat = [conj q.real, conj q.dual]
func conj*(q: DQuat): DQuat      = conjugate q

func norm2*(q: DQuat): float32 =
    let m1 = mag q.real
    let m2 = mag q.dual
    m1^2 + m2^2
func norm*(q: DQuat): float32 = sqrt norm2 q
func mag*(q: DQuat): float32  = norm q

func normalize*(q: var DQuat) =
    normalize q.real
    normalize q.dual
func normalized*(q: DQuat): DQuat =
    result = q
    normalize result

func dquat*(r, d: Quat): DQuat = [normalized r, d]
func dquat*(v: Vec3): DQuat    = [quat(0, 0, 0, 1), quat(v.x/2, v.y/2, v.z/2, 0)]
func dquat*(q: Quat): DQuat    = [normalized q, quat(0, 0, 0, 0)]

func dquat*(n: Vec3; α: Radians; t: Vec3): DQuat =
    let s  = sin(α/2)
    let qt = [quat(0'f32, 0, 0, 1), quat(t.x/2, t.y/2, t.z/2, 0)]
    let qr = [quat(float α*n.x, float α*n.y, float α*n.z, cos(α/2)), quat(0'f32, 0, 0, 0)]
    qt*qr

func dquat*(q: Quat; t: Vec3): DQuat =
    let r = normalized q
    DQuat(real: r, dual: quat(t.x, t.y, t.z, 0)*r*0.5)

func mat*(q: DQuat): Transform3D =
    let q = normalized q
    let (x, y, z, w) = unpack q.real
    let t = 2*q.dual*(conj q.real)
    [[w*w + x*x - y*y - z*z, 2*x*y + 2*w*z        , 2*x*z - 2*w*y        ],
     [2*x*y - 2*w*z        , w*w + y*y - x*x - z*z, 2*y*z + 2*w*x        ],
     [2*x*z + 2*w*y        , 2*y*z - 2*w*x        , w*w + z*z - x*x - y*y],
     [t.x                  , t.y                  , t.z                  ]]

func mat4*(q: DQuat): Mat4 =
    let q = normalized q
    let (x, y, z, w) = unpack q.real
    let t = 2*q.dual*(conj q.real)
    [[w*w + x*x - y*y - z*z, 2*x*y + 2*w*z        , 2*x*z - 2*w*y        , 0],
     [2*x*y - 2*w*z        , w*w + y*y - x*x - z*z, 2*y*z + 2*w*x        , 0],
     [2*x*z + 2*w*y        , 2*y*z - 2*w*x        , w*w + z*z - x*x - y*y, 0],
     [t.x                  , t.y                  , t.z                  , 1]]

func mat3*(q: DQuat): Mat3 =
    let q = normalized q
    let (x, y, z, w) = unpack q.real
    [[w*w + x*x - y*y - z*z, 2*x*y + 2*w*z        , 2*x*z - 2*w*y        ],
     [2*x*y - 2*w*z        , w*w + y*y - x*x - z*z, 2*y*z + 2*w*x        ],
     [2*x*z + 2*w*y        , 2*y*z - 2*w*x        , w*w + z*z - x*x - y*y]]

func translation*(q: DQuat): Vec3 =
    let r = q.real
    let d = q.dual
    2.0f*[d.x*r.w - d.w*r.x - d.y*r.z + d.z*r.y,
          d.y*r.w - d.w*r.y - d.z*r.x + d.x*r.z,
          d.z*r.w - d.w*r.z - d.x*r.y + d.y*r.x]
func trans*(q: DQuat): Vec3 = translation q

func rotation*(q: DQuat): Quat = q.real
func rot*(q: DQuat): Quat      = q.rotation

func translate*(q: var DQuat; v: Vec3) =
    let r = q.real
    let d = q.dual
    let t = v/2.0f
    q.dual = quat(r.w*t.x + r.y*t.z - r.z*t.y + d.x,
                  r.w*t.y + r.z*t.x - r.x*t.z + d.y,
                  r.w*t.z + r.x*t.y - r.y*t.x + d.z,
                 -r.x*t.x - r.y*t.y - r.z*t.z + d.w)
func translated*(q: DQuat; v: Vec3): DQuat =
    result = q
    result.translate v

func rotate*(q: var DQuat; p: Quat) =
    let r = q.real
    let d = q.dual
    q = [quat(r.x*p.w + r.w*p.x + r.y*p.z - r.z*p.y,
              r.y*p.w + r.w*p.y + r.z*p.x - r.x*p.z,
              r.z*p.w + r.w*p.z + r.x*p.y - r.y*p.x,
              r.w*p.w - r.x*p.x - r.y*p.y - r.z*p.z),
         quat(d.x*p.w + d.w*p.x + d.y*p.z - d.z*p.y,
              d.y*p.w + d.w*p.y + d.z*p.x - d.x*p.z,
              d.z*p.w + d.w*p.z + d.x*p.y - d.y*p.x,
              d.w*p.w - d.x*p.x - d.y*p.y - d.z*p.z)]

func rotate*(p: Quat; q: var DQuat) =
    let r = q.real
    let d = q.dual
    q = [quat(p.x*r.w + p.w*r.x + p.y*r.z - p.z*r.y,
              p.y*r.w + p.w*r.y + p.z*r.x - p.x*r.z,
              p.z*r.w + p.w*r.z + p.x*r.y - p.y*r.x,
              p.w*r.w - p.x*r.x - p.y*r.y - p.z*r.z),
         quat(p.x*r.w + p.w*d.x + p.y*d.z - p.z*d.y,
              p.y*r.w + p.w*d.y + p.z*d.x - p.x*d.z,
              p.z*r.w + p.w*d.z + p.x*d.y - p.y*d.x,
              p.w*r.w - p.x*d.x - p.y*d.y - p.z*d.z)]

func rotated*(q: DQuat; p: Quat): DQuat = result = q; result.rotate p
func rotated*(p: Quat; q: DQuat): DQuat = result = q; result.rotate p

func `*`*(q: DQuat; p: Quat): DQuat = q.rotated p
func `*`*(p: Quat; q: DQuat): DQuat = q.rotated p

func `*=`*(q: var DQuat; p: Quat) = q.rotate p

{.pop.}
