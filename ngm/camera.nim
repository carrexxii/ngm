# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, util, vector, matrix, interpolation

type
    ZoomState* = enum
        zsNone
        zsIn
        zsOut

    Camera2D* = object
        pos*       : Vec2
        dir*       : Vec2
        rot*       : Radians
        zoom*      : Real
        zoom_max*  : Real
        zoom_min*  : Real
        zoom_scale*: Real
        pan_speed* : Real
        rot_speed* : Radians
        zoom_speed*: Real
        zoom_state*: ZoomState
        view_w*    : Real
        view_h*    : Real
        view*      : Mat4
        proj*      : Mat4

    ProjectionKind* = enum
        pkPerspective
        pkOrthogonal
    Camera3D* = object
        pos*      : Vec3
        pan_speed*: Real
        dir*      : Vec3
        rot_speed*: Radians
        up*       : Vec3
        proj_kind*: ProjectionKind
        znear*    : Real
        zfar*     : Real
        view*     : Mat4
        proj*     : Mat4
        proj_inv* : Mat4

func right*(cam: Camera3D): Vec3 {.inline.} = normalized (cam.dir × cam.up)
func up*(cam: Camera3D): Vec3    {.inline.} = normalized (cam.right × (cam.dir - cam.pos))

func orthogonal*(l, r, b, t, n, f: Real; zero_to_one = true): Mat4 =
    ## Orthogonal projection matrix with depth clip space \[0..1\]
    ## by default or \[-1..1\] with `zero_to_one = false`.
    if zero_to_one:
        [[2/(r - l)       , 0               , 0         , 0],
         [0               , 2/(t - b)       , 0         , 0],
         [0               , 0               , -1/(f - n), 0],
         [-(r + l)/(r - l), -(t + b)/(t - b), -n/(f - n), 1]]
    else:
        [[2/(r - l)       , 0               , 0               , 0],
         [0               , 2/(t - b)       , 0               , 0],
         [0               , 0               , -2/(f - n)      , 0],
         [-(r + l)/(r - l), -(t + b)/(t - b), -(f + n)/(f - n), 1]]

func orthogonal*(w, h: Real; zero_to_one = true): Mat4 =
    ## Symmetrical orthogonal projection matrix
    if zero_to_one:
        [[2/w, 0  ,  0  , 0],
         [0  , 2/h,  0  , 0],
         [0  , 0  , -0.5, 0],
         [0  , 0  ,  0.5, 1]]
    else:
        [[1/w, 0  ,  0, 0],
         [0  , 1/h,  0, 0],
         [0  , 0  , -1, 0],
         [0  , 0  ,  0, 1]]

func perspective*(l, r, b, t, n, f: Real; zero_to_one = true): Mat4 =
    ## Perspective projection frustum
    ## If `zero_to_one = false`, a clip space of \[-1..1\] is used.
    ##
    ## `f` may be `Inf` for a far plane of \[n, ∞\]
    if f == Inf:
        let m32 = if zero_to_one: -n else: -2*n
        [[2*n*(r - l)    , 0              ,  0  ,  0],
         [0              , 2*n*(t - b)    ,  0  ,  0],
         [(r + l)/(r - l), (t + b)/(t - b), -1  , -1],
         [0              , 0              ,  m32,  0]]
    else:
        let m22 = if zero_to_one: -f/(f - n)   else: -(f + n)/(f - n)
        let m32 = if zero_to_one: -f*n/(f - n) else: -2*f*n/(f - n)
        [[2*n/(r - l)    , 0              , 0  ,  0],
         [0              , 2*n/(t - b)    , 0  ,  0],
         [(r + l)/(r - l), (t + b)/(t - b), m22, -1],
         [0              , 0              , m32,  0]]

func perspective*(ar: Real; fov: Radians; n, f: Real; hfov = true; zero_to_one = true): Mat4 =
    ## Perspective projection matrix using a symmetrical horizontal FoV with
    ## `hfov = true`or a symmetrical vertical FoV with `hfov = false`.
    ##
    ## If `zero_to_one = false`, a clip space of \[-1..1\] is used.
    ##
    ## `f` may be `Inf` for a far plane of \[n, ∞\].
    let c   = cot(fov / 2)
    let m11 = if hfov: c    else: ar*c
    let m22 = if hfov: ar*c else: c
    if f == Inf:
        let m43 = if zero_to_one: -n else: -2*n
        [[m11, 0  ,  0 ,  0],
         [0  , m22,  0 ,  0],
         [0  , 0  , -1 , -1],
         [0  , 0  , m43,  0]]
    else:
        let dr  = -f/(f - n)
        let m33 = if zero_to_one: dr   else: dr + n/(f - n)
        let m43 = if zero_to_one: n*dr else: 2*n*dr
        [[m11, 0  , 0  ,  0],
         [0  , m22, 0  ,  0],
         [0  , 0  , m33, -1],
         [0  , 0  , m43,  0]]

func update*(cam: var Camera2D; dt: Real) =
    if cam.zoom_state != zsNone:
        cam.zoom += cam.zoom_speed*(if cam.zoom_state == zsIn: dt else: -dt)
        cam.zoom = cam.zoom.clamp(0, 1)
        let zoom = lerp(cam.zoom_min, cam.zoom_max, ease_in cam.zoom)
        cam.proj = orthogonal(cam.view_w / zoom, cam.view_h / zoom)

    let l = lerp(cam.zoom_scale, 1/cam.zoom_scale, cam.zoom)
    cam.pos += dt * cam.pan_speed*l * normalized cam.dir
    let
        x = cam.pos.x
        y = cam.pos.y
        c = cos cam.rot
        s = sin cam.rot
    cam.view = [[c, -s, 0, 0],
                [s,  c, 0, 0],
                [0,  0, 1, 0],
                [x,  y, 0, 1]]

{.push inline.}

func move*(cam: var Camera2D; dir: Vec2) =
    cam.dir += dir

func yaw*(cam: var Camera3D; α: Radians)   = cam.dir.rotate α, cam.up
func pitch*(cam: var Camera3D; α: Radians) = cam.dir.rotate α, cam.right
func roll*(cam: var Camera3D; α: Radians)  = cam.up.rotate  α, cam.dir

func create_camera2d*(pos        = vec(0, 0);
                      dir        = vec(0, 0);
                      rot        = 0.0'rad;
                      zoom       = 0.5;
                      zoom_max   = 3000.0;
                      zoom_min   = 10.0;
                      zoom_scale = 5.0;
                      pan_speed  = 3.0;
                      rot_speed  = 1.0'rad;
                      zoom_speed = 1.0;
                      view_w     = 1920.0;
                      view_h     = 1080.0
                      ): Camera2D =
    result = Camera2D(
        pos       : pos,
        dir       : dir,
        rot       : rot,
        zoom      : zoom,
        zoom_max  : zoom_max,
        zoom_min  : zoom_min,
        zoom_scale: zoom_scale,
        pan_speed : pan_speed,
        rot_speed : rot_speed,
        zoom_speed: zoom_speed,
        zoom_state: zsIn,
        view_w    : view_w,
        view_h    : view_h,
        view      : Mat4Ident,
        proj      : Mat4Ident,
    )
    result.update 0
    result.zoom_state = zsNone

{.pop.}
