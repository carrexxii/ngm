# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, vector, matrix, quat
from std/strformat import `&`

type DQuat* = distinct array[2, Quat]

converter `DQuat -> ptr DQuat`(q: DQuat): ptr DQuat = q.addr

func `[]`*(q: DQuat; i: SomeInteger): Quat =
    cast[array[2, Quat]](q)[i]

func `$`*(q: DQuat): string = &"Dual Quaternion [{cast[Vec4](q[0])}; {cast[Vec4](q[1])}]"

{.push header: CGLMDir / "dquat.h".}
proc glm_dquat*(q: ptr DQuat; r, d: ptr Quat)            {.importc: "glm_dquat" .}
proc glm_dquatv*(q: ptr DQuat; r: ptr Quat; t: ptr Vec3) {.importc: "glm_dquatv".}

proc glm_dquat_conjugate*(q, dst: ptr DQuat)             {.importc: "glm_dquat_conjugate"   .}
proc glm_dquat_norm*(q: ptr DQuat): float32              {.importc: "glm_dquat_norm"        .}
proc glm_dquat_normalize*(q: ptr DQuat)                  {.importc: "glm_dquat_normalize"   .}
proc glm_dquat_normalize_to*(q, dst: ptr DQuat)          {.importc: "glm_dquat_normalize_to".}
proc glm_dquat_rotation*(q: ptr DQuat; dst: ptr Quat)    {.importc: "glm_dquat_rotation"    .}
proc glm_dquat_translation*(q: ptr DQuat; dst: ptr Vec3) {.importc: "glm_dquat_translation" .}
proc glm_dquat_mat*(q: ptr DQuat; dst: ptr Mat4)         {.importc: "glm_dquat_mat"         .}

proc glm_dquat_add*(q, p, dst: ptr DQuat)                       {.importc: "glm_dquat_add"  .}
proc glm_dquat_sub*(q, p, dst: ptr DQuat)                       {.importc: "glm_dquat_sub"  .}
proc glm_dquat_mul*(q, p, dst: ptr DQuat)                       {.importc: "glm_dquat_mul"  .}
proc glm_dquat_div*(q, p, dst: ptr DQuat)                       {.importc: "glm_dquat_div"  .}
proc glm_dquat_scale*(q: ptr DQuat; p: float32; dst: ptr DQuat) {.importc: "glm_dquat_scale".}
proc glm_dquat_dot*(q, p: ptr DQuat): float32                   {.importc: "glm_dquat_dot"  .}
{.pop.}

{.push inline.}

func dquat*(r, d: Quat)      : DQuat = glm_dquat(result, r, d)
func dquat*(r: Quat; t: Vec3): DQuat = glm_dquatv(result, r, t)

func conjugate*(q: DQuat): DQuat = glm_dquat_conjugate(q, result)
func conj*(q: DQuat)     : DQuat = q.conjugate

func norm*(q: DQuat): float32 = glm_dquat_norm q
func mag*(q: DQuat) : float32 = q.norm

func normalize*(q: var DQuat)     = glm_dquat_normalize q
func normalized*(q: DQuat): DQuat = glm_dquat_normalize_to(q, result)

func rotation*(q: DQuat): Quat = glm_dquat_rotation(q, result)
func rot*(q: DQuat)     : Quat = q.rotation

func translation*(q: DQuat): Vec3 = glm_dquat_translation(q, result)
func trans*(q: DQuat)      : Vec3 = q.translation

func mat*(q: DQuat): Mat4 = glm_dquat_mat(q, result)

func dot*(q, p: DQuat): float32 = glm_dquat_dot(q, p)

func `+`*(q, p: DQuat): DQuat = glm_dquat_add(q, p, result)
func `-`*(q, p: DQuat): DQuat = glm_dquat_sub(q, p, result)
func `*`*(q, p: DQuat): DQuat = glm_dquat_mul(q, p, result)
func `/`*(q, p: DQuat): DQuat = glm_dquat_div(q, p, result)
func `*`*(q: DQuat; s: float32): DQuat = glm_dquat_scale(q, s, result)
func `∙`*(q, p: DQuat): float32 = dot(q, p)

func `+=`*(q, p: var DQuat) = q = q + p
func `-=`*(q, p: var DQuat) = q = q - p
func `*=`*(q, p: var DQuat) = q = q * p
func `/=`*(q, p: var DQuat) = q = q / p
func `*=`*(q: var DQuat; s: float32) = q = q * s

{.pop.}

const DQuatIdent* = DQuat [Quat [0'f32, 0, 0, 1], Quat [0'f32, 0, 0, 0]]
