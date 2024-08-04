# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, util, vector, matrix
from std/strformat import `&`

type Quat* = distinct Vector[4, float32]

converter `Quat -> ptr Quat`*(q: Quat): ptr Quat = q.addr

func `[]`*(q: Quat; i: SomeInteger): float32 =
    cast[array[4, float32]](q)[i]

func quat*(x, y, z, w: float32): Quat = Quat [x, y, z, w]

const QuatIdent* = quat(0, 0, 0, 1)

#[ -------------------------------------------------------------------- ]#

{.push header: CGLMDir / "quat.h".}
proc glm_quat*(q: ptr Quat; angle: Radians; x, y, z: float32) {.importc: "glm_quat"          .}
proc glm_quat_from_vecs*(v, u: ptr Vec3; dst: ptr Quat)       {.importc: "glm_quat_from_vecs".}

proc glm_quat_norm*(q: ptr Quat): float32     {.importc: "glm_quat_norm"        .}
proc glm_quat_normalize*(q: ptr Quat)         {.importc: "glm_quat_normalize"   .}
proc glm_quat_normalize_to*(q, dst: ptr Quat) {.importc: "glm_quat_normalize_to".}
proc glm_quat_dot*(q, p: ptr Quat): float32   {.importc: "glm_quat_dot"         .}
proc glm_quat_conjugate*(q, dst: ptr Quat)    {.importc: "glm_quat_conjugate"   .}
proc glm_quat_inv*(q, dst: ptr Quat)          {.importc: "glm_quat_inv"         .}
proc glm_quat_add*(q, p, dst: ptr Quat)       {.importc: "glm_quat_add"         .}
proc glm_quat_sub*(q, p, dst: ptr Quat)       {.importc: "glm_quat_sub"         .}
proc glm_quat_angle*(q: ptr Quat): float32    {.importc: "glm_quat_angle"       .}
proc glm_quat_mul*(q, p, dst: ptr Quat)       {.importc: "glm_quat_mul"         .}

proc glm_quat_mat4*(q: ptr Quat; dst: ptr Mat4)    {.importc: "glm_quat_mat4" .}
proc glm_quat_mat4t*(q: ptr Quat; dst: ptr Mat4)   {.importc: "glm_quat_mat4t".}
proc glm_quat_mat3*(q: ptr Quat; dst: ptr Mat3x3)  {.importc: "glm_quat_mat3" .}
proc glm_quat_mat3t*(q: ptr Quat; dst: ptr Mat3x3) {.importc: "glm_quat_mat3t".}

proc glm_quat_lerp*(`from`, to: ptr Quat; t: float32; dst: ptr Quat)  {.importc: "glm_quat_lerp" .}
proc glm_quat_lerpc*(`from`, to: ptr Quat; t: float32; dst: ptr Quat) {.importc: "glm_quat_lerpc".}
proc glm_quat_slerp*(`from`, to: ptr Quat; t: float32; dst: ptr Quat) {.importc: "glm_quat_slerp".}
proc glm_quat_nlerp*(`from`, to: ptr Quat; t: float32; dst: ptr Quat) {.importc: "glm_quat_nlerp".}

proc glm_quat_look*(eye: ptr Vec3; orientation: ptr Quat; dst: ptr Mat4)                 {.importc: "glm_quat_look"   .}
proc glm_quat_for*(dir, fwd, up: ptr Vec3; dst: ptr Quat)                                {.importc: "glm_quat_for"    .}
proc glm_quat_forp*(`from`, to, fwd, up: ptr Vec3; orientation: ptr Quat; dst: ptr Mat4) {.importc: "glm_quat_forp"   .}
proc glm_quat_rotatev*(q: ptr Quat; v, dst: ptr Vec3)                                    {.importc: "glm_quat_rotatev".}
proc glm_quat_rotate*(m: ptr Mat4; q: ptr Quat; dst: ptr Mat4)                           {.importc: "glm_quat_rotate" .}
{.pop.}

{.push inline.}

func quat*(angle: Radians; x, y, z: float32): Quat = glm_quat(result, angle, x, y, z)
func versor*(v, u: Vec3): Quat = glm_quat_from_vecs(v, u, result)
func versor*(x, y, z, w: float32): Quat =
    result = quat(x, y, z, w)
    glm_quat_normalize result

func angle*(q: Quat): float32 = glm_quat_angle q
func norm*(q: Quat) : float32 = glm_quat_norm  q
func mag*(q: Quat)  : float32 = glm_quat_norm  q

func conjugate*(q: Quat): Quat = glm_quat_conjugate(q, result)
func conj*(q: Quat)     : Quat = glm_quat_conjugate(q, result)

func `$`*(q: Quat): string = &"Quaternion [{q[0]:.2f}, {q[1]:.2f}, {q[2]:.2f}, {q[3]:.2f} ({q.mag:.2f})]"

func `+`*(q, p: Quat): Quat    = glm_quat_add(q, p, result)
func `-`*(q, p: Quat): Quat    = glm_quat_sub(q, p, result)
func `∙`*(q, p: Quat): float32 = glm_quat_dot(q, p)

func `+=`*(q: var Quat; p: Quat) = q = q + p
func `-=`*(q: var Quat; p: Quat) = q = q - p

func mat4*(q: Quat): Mat4 = glm_quat_mat4(q, result)
func mat3*(q: Quat): Mat3 = glm_quat_mat3(q, result)

func mat4_transposed*(q: Quat): Mat4 = glm_quat_mat4t(q, result)
func mat3_transposed*(q: Quat): Mat3 = glm_quat_mat3t(q, result)

func lerp*(`from`, to: Quat; t: float32) : Quat = glm_quat_lerp(`from`, to, t, result)
func lerpc*(`from`, to: Quat; t: float32): Quat = glm_quat_lerpc(`from`, to, t, result)
func slerp*(`from`, to: Quat; t: float32): Quat = glm_quat_slerp(`from`, to, t, result)
func nlerp*(`from`, to: Quat; t: float32): Quat = glm_quat_nlerp(`from`, to, t, result)

func rotate*(q: Quat; v: var Vec3)    = glm_quat_rotatev(q, v, v)
func rotated*(q: Quat; v: Vec3): Vec3 = glm_quat_rotatev(q, v, result)

func rotate*(q: Quat; m: var Mat4)    = glm_quat_rotate(m, q, m)
func rotated*(q: Quat; m: Mat4): Mat4 = glm_quat_rotate(m, q, result)

func look*(eye: Vec3; orientation: Quat): Mat4 = glm_quat_look(eye, orientation, result)

{.pop.}
