import common, vector, matrix

type
    # + Fixed rotation ?
    CameraKind* = enum
        Orthogonal
        Perspective

    Camera* = object
        view*: Mat4
        proj*: Mat4
        pos* : Vec3
        case kind*: CameraKind
        of Perspective:
            dir*: Vec3
            up* : Vec3
        of Orthogonal:
            discard

    PanDirection* = enum
        Up
        Down
        Left
        Right

#[ -------------------------------------------------------------------- ]#

using
    dst : ptr Mat4
    proj: ptr Mat4

{.emit: CGLMInclude.}
{.push header: CGLMDir / "cam.h".}
proc frustum*(left, right, bottom, top, znear, zfar: cfloat; dst)           {.importc: "glm_frustum"            .}
proc ortho*(left, right, bottom, top, znear, zfar: cfloat; dst)             {.importc: "glm_ortho"              .}
proc ortho_aabb*(box: ptr array[2, Vec3]; dst)                              {.importc: "glm_ortho_aabb"         .}
proc ortho_aabb_p*(box: ptr array[2, Vec3]; padding: cfloat; dst)           {.importc: "glm_ortho_aabb_p"       .}
proc ortho_aabb_pz*(box: ptr array[2, Vec3]; padding: cfloat; dst)          {.importc: "glm_ortho_aabb_pz"      .}
proc ortho_default*(aspect: cfloat; dst)                                    {.importc: "glm_ortho_default"      .}
proc ortho_default_s*(aspect, size: cfloat; dst)                            {.importc: "glm_ortho_default_s"    .}
proc perspective*(yfov, aspect, znear, zfar: cfloat; dst)                   {.importc: "glm_perspective"        .}
proc perspective_default*(aspect: cfloat; dst)                              {.importc: "glm_perspective_default".}
proc perspective_resize*(aspect: cfloat; proj)                              {.importc: "glm_perspective_resize" .}
proc lookat*(eye, centre, up: ptr Vec3; dst)                                {.importc: "glm_lookat"             .}
proc look*(eye, dir, up: ptr Vec3; dst)                                     {.importc: "glm_look"               .}
proc look_anyup*(eye, dir: ptr Vec3; dst)                                   {.importc: "glm_look_anyup"         .}
proc persp_decomp*(proj; znear, zfar, top, bottom, left, right: ptr cfloat) {.importc: "glm_persp_decomp"       .}
proc persp_decompv*(proj; dst: ptr array[6, cfloat])                        {.importc: "glm_persp_decompv"      .}
proc persp_decomp_x*(proj; left, right: ptr cfloat)                         {.importc: "glm_persp_decomp_x"     .}
proc persp_decomp_y*(proj; top, bottom: ptr cfloat)                         {.importc: "glm_persp_decomp_y"     .}
proc persp_decomp_z*(proj; near, far: ptr cfloat)                           {.importc: "glm_persp_decomp_z"     .}
proc persp_decomp_far*(proj; zfar: ptr cfloat)                              {.importc: "glm_persp_decomp_far"   .}
proc persp_decomp_near*(proj; znear: ptr cfloat)                            {.importc: "glm_persp_decomp_near"  .}
proc persp_fovy*(proj): cfloat                                              {.importc: "glm_persp_fovy"         .}
proc persp_aspect*(proj): cfloat                                            {.importc: "glm_persp_aspect"       .}
proc persp_sizes*(proj; yfov: cfloat; dst: ptr Vec4)                        {.importc: "glm_persp_sizes"        .}
{.pop.}

{.push inline.}

proc orthogonal*(left, right, bottom, top, znear, zfar: float32): Mat4 =
    ortho(left, right, bottom, top, znear, zfar, result.addr)

proc orthogonal_default*(aspect: float32 = 16/9): Mat4 =
    ortho_default(aspect, result.addr)

proc perspective*(yfov, aspect, znear, zfar: float32): Mat4 =
    perspective(yfov, aspect, znear, zfar, result.addr)

proc perspective_default*(aspect: float32 = 16/9): Mat4 =
    perspective_default(aspect, result.addr)

proc look_at*(eye, centre, up: Vec3): Mat4 = lookat(eye.addr, centre.addr, up.addr, result.addr)
proc look*(eye, dir, up: Vec3)      : Mat4 = lookat(eye.addr, dir.addr, up.addr, result.addr)

#[ -------------------------------------------------------------------- ]#

proc camera*(left, right, bottom, top, znear, zfar: float32): Camera =
    Camera(kind: Orthogonal,
           view: Mat4Ident,
           proj: orthogonal(left, right, bottom, top, znear, zfar))

proc camera*(yfov, aspect, znear, zfar: float32; pos, dir, up = vec(0, 0, 0)): Camera =
    Camera(kind: Perspective,
           pos : pos,
           dir : dir,
           up  : up,
           view: Mat4Ident,
           proj: perspective(yfov, aspect, znear, zfar))

proc look_at*(cam: var Camera; eye, centre, up: Vec3) = lookat(eye.addr, centre.addr, up.addr, cam.view.addr)
proc look*(cam: var Camera; eye, dir, up: Vec3)       = look(eye.addr, dir.addr, up.addr, cam.view.addr)
proc look*(cam: var Camera; eye, dir: Vec3)           = look_anyup(eye.addr, dir.addr, cam.view.addr)

proc update*(cam: var Camera) =
    cam.look(cam.pos, cam.dir, cam.up)

proc pan*(cam: var Camera; dir: PanDirection) =
    let vdir = case dir
    of Up   :  cam.up
    of Down : -cam.up
    of Left : -cross(cam.dir, cam.up)
    of Right:  cross(cam.dir, cam.up)
    cam.pos += 0.1*(normalized vdir)

{.pop.}

