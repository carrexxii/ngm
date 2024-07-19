# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, vector, matrix

type AABB* = array[2, Vec2]

{.push header: CGLMDir / "aabb2d.h".}
proc glm_aabb2d_transform*(aabb: ptr AABB; mat: ptr Mat3x3; dst: ptr AABB) {.importc: "glm_aabb2d_transform" .}
proc glm_aabb2d_merge*(aabb1, aabb2, dst: ptr AABB)                        {.importc: "glm_aabb2d_merge"     .}
proc glm_aabb2d_crop*(aabb, crop_aabb, dst: ptr AABB)                      {.importc: "glm_aabb2d_crop"      .}
proc glm_aabb2d_crop_until*(aabb, crop_aabb, clamp_aabb, dst: ptr AABB)    {.importc: "glm_aabb2d_crop_until".}
proc glm_aabb2d_diag*(aabb: ptr AABB): float32                             {.importc: "glm_aabb2d_diag"      .}
proc glm_aabb2d_sizev*(aabb: ptr AABB; dst: ptr Vec2)                      {.importc: "glm_aabb2d_sizev"     .}
proc glm_aabb2d_radius*(aabb: ptr AABB): float32                           {.importc: "glm_aabb2d_radius"    .}
proc glm_aabb2d_center*(aabb: ptr AABB; dst: ptr Vec2)                     {.importc: "glm_aabb2d_center"    .}
proc glm_aabb2d_aabb*(aabb1, aabb2: ptr AABB): bool                        {.importc: "glm_aabb2d_aabb"      .}
proc glm_aabb2d_circle*(aabb: ptr AABB; c: ptr Vec3): bool                 {.importc: "glm_aabb2d_circle"    .}
proc glm_aabb2d_point*(aabb: ptr AABB; c: ptr Vec2): bool                  {.importc: "glm_aabb2d_point"     .}
proc glm_aabb2d_contains*(aabb1, aabb2: ptr AABB): bool                    {.importc: "glm_aabb2d_contains"  .}
{.pop.}

func `in`*(p: Vec2; a: AABB): bool = glm_aabb2d_point a.addr, p.addr

