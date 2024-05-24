import common, vector, matrix

#const CameraHeader = CGLMDir & "/cam.h"

using
    dst : ptr Mat4
    proj: ptr Mat4

{.push header: CGLMHeader.}
proc frustum*(left, right, bottom, top, z_near, z_far: float; dst)            {.importc: "glm_frustum"            .}
proc ortho*(left, right, bottom, top, z_near, z_far: float; dst)              {.importc: "glm_ortho"              .}
proc ortho_aabb*(box: array[2, Vec3]; dst)                                    {.importc: "glm_ortho_aabb"         .}
proc ortho_aabb_p*(box: array[2, Vec3]; padding: cfloat; dst)                 {.importc: "glm_ortho_aabb_p"       .}
proc ortho_aabb_pz*(box: array[2, Vec3]; padding: cfloat; dst)                {.importc: "glm_ortho_aabb_pz"      .}
proc ortho_default*(aspect: cfloat; dst)                                      {.importc: "glm_ortho_default"      .}
proc ortho_default_s*(aspect, size: cfloat; dst)                              {.importc: "glm_ortho_default_s"    .}
proc perspective*(y_fov, aspect, z_near, z_far: cfloat; dst)                  {.importc: "glm_perspective"        .}
proc perspective_default*(aspect: cfloat; dst)                                {.importc: "glm_perspective_default".}
proc perspective_resize*(aspect: cfloat; proj)                                {.importc: "glm_perspective_resize" .}
proc lookat*(eye, centre, up: ptr Vec3; dst)                                  {.importc: "glm_lookat"             .}
proc look*(eye, dir, up: ptr Vec3; dst)                                       {.importc: "glm_look"               .}
proc look_anyup*(eye, dir: ptr Vec3; dst)                                     {.importc: "glm_look_anyup"         .}
proc persp_decomp*(proj; z_near, z_far, top, bottom, left, right: ptr cfloat) {.importc: "glm_persp_decomp"       .}
proc persp_decompv*(proj; dst: ptr array[6, cfloat])                          {.importc: "glm_persp_decompv"      .}
proc persp_decomp_x*(proj; left, right: ptr cfloat)                           {.importc: "glm_persp_decomp_x"     .}
proc persp_decomp_y*(proj; top, bottom: ptr cfloat)                           {.importc: "glm_persp_decomp_y"     .}
proc persp_decomp_z*(proj; near, far: ptr cfloat)                             {.importc: "glm_persp_decomp_z"     .}
proc persp_decomp_far*(proj; z_far: ptr cfloat)                               {.importc: "glm_persp_decomp_far"   .}
proc persp_decomp_near*(proj; z_near: ptr cfloat)                             {.importc: "glm_persp_decomp_near"  .}
proc persp_fovy*(proj): cfloat                                                {.importc: "glm_persp_fovy"         .}
proc persp_aspect*(proj): cfloat                                              {.importc: "glm_persp_aspect"       .}
proc persp_sizes*(proj; y_fov: cfloat; dst: ptr Vec4)                         {.importc: "glm_persp_sizes"        .}
{.pop.}
