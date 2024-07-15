# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, vector, matrix

type
    CameraProjection* = enum
        cpOrthogonal
        cpPerspective

    CameraDirection* = enum
        cdForwards
        cdBackwards
        cdUp
        cdDown
        cdLeft
        cdRight

type Camera* = object
    proj_kind*: CameraProjection
    pan_speed*: float32 = 0.1'f32
    rot_speed*: float32 = 0.1'f32
    pos*      : Vec3 = vec(1, 1, 1)
    target*   : Vec3 = vec(0, 0, 0)
    up*       : Vec3 = vec(0, 1, 0)
    view*     : Mat4x4 = Mat4x4Ident
    proj*     : Mat4x4 = Mat4x4Ident

func dir*(cam: Camera): Vec3 {.inline.} =
    cam.target - cam.pos

func right*(cam: Camera): Vec3 {.inline.} =
    normalized (cam.dir × cam.up)

#[ -------------------------------------------------------------------- ]#

using
    dst : ptr Mat4x4
    proj: ptr Mat4x4

{.emit: CGLMInclude.}
{.push header: CGLMDir / "cam.h".}
proc glm_frustum*(left, right, bottom, top, znear, zfar: cfloat; dst) {.importc: "glm_frustum"   .}
proc glm_lookat*(eye, centre, up: ptr Vec3; dst)                      {.importc: "glm_lookat"    .}
proc glm_look*(eye, dir, up: ptr Vec3; dst)                           {.importc: "glm_look"      .}
proc glm_look_anyup*(eye, dir: ptr Vec3; dst)                         {.importc: "glm_look_anyup".}

proc glm_ortho*(left, right, bottom, top, znear, zfar: cfloat; dst)    {.importc: "glm_ortho"          .}
proc glm_ortho_aabb*(box: ptr array[2, Vec3]; dst)                     {.importc: "glm_ortho_aabb"     .}
proc glm_ortho_aabb_p*(box: ptr array[2, Vec3]; padding: cfloat; dst)  {.importc: "glm_ortho_aabb_p"   .}
proc glm_ortho_aabb_pz*(box: ptr array[2, Vec3]; padding: cfloat; dst) {.importc: "glm_ortho_aabb_pz"  .}
proc glm_ortho_default*(aspect: cfloat; dst)                           {.importc: "glm_ortho_default"  .}
proc glm_ortho_default_s*(aspect, size: cfloat; dst)                   {.importc: "glm_ortho_default_s".}

proc glm_perspective*(yfov, aspect, znear, zfar: cfloat; dst)                   {.importc: "glm_perspective"        .}
proc glm_perspective_default*(aspect: cfloat; dst)                              {.importc: "glm_perspective_default".}
proc glm_perspective_resize*(aspect: cfloat; proj)                              {.importc: "glm_perspective_resize" .}
proc glm_persp_decomp*(proj; znear, zfar, top, bottom, left, right: ptr cfloat) {.importc: "glm_persp_decomp"       .}
proc glm_persp_decompv*(proj; dst: ptr array[6, cfloat])                        {.importc: "glm_persp_decompv"      .}
proc glm_persp_decomp_x*(proj; left, right: ptr cfloat)                         {.importc: "glm_persp_decomp_x"     .}
proc glm_persp_decomp_y*(proj; top, bottom: ptr cfloat)                         {.importc: "glm_persp_decomp_y"     .}
proc glm_persp_decomp_z*(proj; near, far: ptr cfloat)                           {.importc: "glm_persp_decomp_z"     .}
proc glm_persp_decomp_far*(proj; zfar: ptr cfloat)                              {.importc: "glm_persp_decomp_far"   .}
proc glm_persp_decomp_near*(proj; znear: ptr cfloat)                            {.importc: "glm_persp_decomp_near"  .}
proc glm_persp_fovy*(proj): cfloat                                              {.importc: "glm_persp_fovy"         .}
proc glm_persp_aspect*(proj): cfloat                                            {.importc: "glm_persp_aspect"       .}
proc glm_persp_sizes*(proj; yfov: cfloat; dst: ptr Vec4)                        {.importc: "glm_persp_sizes"        .}
{.pop.}

{.push inline.}

proc orthogonal*(left, right, bottom, top, znear, zfar: float32): Mat4x4 =
    glm_ortho left, right, bottom, top, znear, zfar, result

proc orthogonal_default*(aspect: float32 = 16/9): Mat4x4 =
    glm_ortho_default aspect, result

proc perspective*(yfov, aspect, znear, zfar: float32): Mat4x4 =
    glm_perspective yfov, aspect, znear, zfar, result

proc perspective_default*(aspect: float32 = 16/9): Mat4x4 =
    glm_perspective_default aspect, result

{.pop.}

#[ -------------------------------------------------------------------- ]#

{.push inline.}

func look*(cam: var Camera) =
    glm_look cam.pos, cam.dir, cam.up, cam.view

func set_orthogonal*(cam: var Camera; l, r, b, t, zn, zf: float32) =
    cam.proj = orthogonal(l, r, b, t, zn, zf)

func set_perspective*(cam: var Camera; fov, aspect, znear, zfar: float32) =
    cam.proj = perspective(fov, aspect, znear, zfar)

func update*(cam: var Camera) =
    look cam

{.pop.}

func move*(cam: var Camera; dir: CameraDirection) =
    case dir
    of cdForwards, cdBackwards:
        var fwd = cam.dir
        if cam.proj_kind == cpOrthogonal:
            fwd.y = 0
            normalize fwd

        fwd *= (if dir == cdForwards: cam.pan_speed else: -cam.pan_speed)
        cam.pos    += fwd
        cam.target += fwd
    of cdUp, cdDown:
        let dist = cam.up * (if dir == cdUp: cam.pan_speed else: -cam.pan_speed)
        cam.pos    += dist
        cam.target += dist
    of cdLeft, cdRight:
        var right = cam.right
        if cam.proj_kind == cpOrthogonal:
            right.y = 0
            normalize right

        right *= (if dir == cdRight: cam.pan_speed else: -cam.pan_speed)
        cam.pos    += right
        cam.target += right

proc move*(cam: var Camera) =
    var dist = cam.pos <-> cam.target
    dist += cam.pan_speed
    dist = -max(dist, 0.00001)
    cam.pos = cam.target + (cam.dir * dist)

