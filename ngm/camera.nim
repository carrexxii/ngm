# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, util, vector, matrix

type
    CameraProjection* = enum
        cpOrthogonal
        cpPerspective

    CameraDirection* = enum
        cdNone
        cdForwards
        cdBackwards
        cdUp
        cdDown
        cdLeft
        cdRight

type
    Camera2D* = object
        speed*: float32 = 10.0'f32
        angle*: float32 = 0.0'f32
        zoom* : float32 = 1.0'f32
        pos*  : Vec3 = vec(0, 0, 0)
        view* : Mat4x4 = Mat4x4Ident
        proj* : Mat4x4 = Mat4x4Ident

    Camera3D* = object
        proj_kind*: CameraProjection
        pan_speed*: float32 = 0.1'f32
        rot_speed*: float32 = 0.1'f32
        pos*      : Vec3 = vec(1, 1, 1)
        target*   : Vec3 = vec(0, 0, 0)
        up*       : Vec3 = vec(0, 1, 0)
        view*     : Mat4x4 = Mat4x4Ident
        proj*     : Mat4x4 = Mat4x4Ident

func dir*(cam: Camera3D): Vec3 {.inline.} =
    cam.target - cam.pos

func right*(cam: Camera3D): Vec3 {.inline.} =
    normalized (cam.dir × cam.up)

#[ -------------------------------------------------------------------- ]#

using
    dst : ptr Mat4x4
    proj: ptr Mat4x4

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

func look*(cam: var Camera3D) =
    glm_look cam.pos, cam.dir, cam.up, cam.view

func set_orthogonal*(cam: var (Camera2D | Camera3D); aspect: float32) =
    when cam is Camera3D:
        cam.proj_kind = cpOrthogonal
    cam.proj = orthogonal_default aspect

func set_orthogonal*(cam: var (Camera2D | Camera3D); l, r, b, t, zn, zf: float32) =
    when cam is Camera3D:
        cam.proj_kind = cpOrthogonal
    cam.proj = orthogonal(l, r, b, t, zn, zf)

func set_orthogonal*(cam: var Camera2D; w, h: SomeNumber) =
    let w = (float32 w) / 2 / cam.zoom
    let h = (float32 h) / 2 / cam.zoom
    cam.set_orthogonal -w, w, -h, h, -1, 1

func set_perspective*(cam: var (Camera2D | Camera3D); fov, aspect, znear, zfar: float32) =
    when cam is Camera3D:
        cam.proj_kind = cpPerspective
    cam.proj = perspective(fov, aspect, znear, zfar)

func update*(cam: var Camera2D) =
    cam.view[3].x = cam.pos.x
    cam.view[3].y = cam.pos.y
    cam.view[3].z = cam.pos.z

func update*(cam: var Camera3D) =
    if cam.proj_kind == cpPerspective:
        look cam

{.pop.}

func yaw*(cam: var Camera3D; angle: Radians) {.inline.} =
    cam.target = cam.pos + cam.dir.rotated(cam.up, angle)

func pitch*(cam: var Camera3D; angle: Radians; lock_view = true) {.inline.} =
    var target = cam.dir
    var angle_to_rotate = angle
    if lock_view:
        let max_angle_up   = cam.up.angle target
        let max_angle_down = (-cam.up).angle target
        angle_to_rotate = angle_to_rotate.clamp(-max_angle_down, max_angle_up)

    target.rotate cam.right, angle_to_rotate
    cam.target = cam.pos + target

func roll*(cam: var Camera3D; angle: Radians) {.inline.} =
    cam.up.rotate cam.dir, angle

func move*(cam: var Camera2D; dir: CameraDirection; dt: float) =
    case dir
    of cdNone: return
    of cdUp   : cam.pos.y -= cam.speed * dt
    of cdDown : cam.pos.y += cam.speed * dt
    of cdLeft : cam.pos.x += cam.speed * dt
    of cdRight: cam.pos.x -= cam.speed * dt
    else: assert false, "Zooming"

func move*(cam: var Camera3D; dir: CameraDirection) =
    case dir
    of cdNone: discard
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

func move*(cam: var Camera3D; mouse_delta: Vec2; mouse_sensitivity = DefaultMouseSensitivity) =
    cam.yaw   Radians (mouse_delta.x * mouse_sensitivity)
    cam.pitch Radians (mouse_delta.y * mouse_sensitivity)

