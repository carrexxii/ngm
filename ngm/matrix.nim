# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, vector
from std/strutils import join

type
    Matrix*[N: static int, T: Vector] = array[N, T]

    Mat2x2* = Matrix[2, Vec2]
    Mat3x3* = Matrix[3, Vec3]
    Mat4x4* = Matrix[4, Vec4]

    Mat2* = Mat2x2
    Mat3* = Mat3x3
    Mat4* = Mat4x4

const
    Mat2x2Ident*: Mat2x2 = [[1, 0],
                            [0, 1]]
    Mat3x3Ident*: Mat3x3 = [[1, 0, 0],
                            [0, 1, 0],
                            [0, 0, 1]]
    Mat4x4Ident*: Mat4x4 = [[1, 0, 0, 0],
                            [0, 1, 0, 0],
                            [0, 0, 1, 0],
                            [0, 0, 0, 1]]

func `$`*(m: Mat2x2 | Mat3x3 | Mat4x4): string =
    "[" & (m.join ",\n ") & "]"

converter `Matrix -> ptr Matrix`*(m: Matrix): ptr Matrix = m.addr

#[ -------------------------------------------------------------------- ]#

using
    mp, m1p, m2p, dstmp: ptr Mat4x4
    m , m1 , m2 , dstm :     Mat4x4
    v3p, dstv3p, axisp: ptr Vec3
    v3 , dstv3 , axis :     Vec3
    v4p, dstv4p: ptr Vec4
    v4 , dstv4 :     Vec4
    cs, cangle: cfloat
    s ,  angle: float32

{.push header: CGLMDir / "mat4.h".}
proc mul*(m1p, m2p, dstmp)                 {.importc: "glm_mat4_mul"  .}
proc scale*(mp; cs)                        {.importc: "glm_mat4_scale".}
proc inv*(mp, dstmp)                       {.importc: "glm_mat4_inv"  .}
proc det*(mp): cfloat                      {.importc: "glm_mat4_det"  .}
proc mulv*(mp; v4p; dstv4p)                {.importc: "glm_mat4_mulv" .}
proc mulv3*(mp; v3p; last: cfloat; dstv3p) {.importc: "glm_mat4_mulv3".}
{.pop.}

{.push header: CGLMDir / "affine.h".}
proc translate_to*(mp; v3p; dstmp) {.importc: "glm_translate_to"  .}
proc translate*(mp; v3p)           {.importc: "glm_translate"     .}
proc translate_x*(mp; cs)          {.importc: "glm_translate_x"   .}
proc translate_y*(mp; cs)          {.importc: "glm_translate_y"   .}
proc translate_z*(mp; cs)          {.importc: "glm_translate_z"   .}
proc translate_make*(mp; v3p)      {.importc: "glm_translate_make".}

proc scale_to*(mp; v3p; dstmp) {.importc: "glm_scale_to"  .}
proc scale_make*(mp; v3p)      {.importc: "glm_scale_make".}
proc scale*(mp; v3p)           {.importc: "glm_scale"     .}
proc scale_uni*(mp; cs)        {.importc: "glm_scale_uni" .}

proc rotate_x*(mp; cangle; dstmp)    {.importc: "glm_rotate_x"   .}
proc rotate_y*(mp; cangle; dstmp)    {.importc: "glm_rotate_y"   .}
proc rotate_z*(mp; cangle; dstmp)    {.importc: "glm_rotate_z"   .}
proc rotate_make*(mp; cangle; axisp) {.importc: "glm_rotate_make".}
proc rotate*(mp; cangle; axisp)      {.importc: "glm_rotate"     .}
proc spin*(mp; cangle; axisp)        {.importc: "glm_spin"       .}
{.pop.}

{.push header: CGLMDir / "project.h".}
proc unprojecti*(v: ptr Vec3; inv_mat: ptr Mat4x4; viewport: ptr Vec4; dst: ptr Vec3) {.importc: "glm_unprojecti".}
proc unproject*(v: ptr Vec3; mat: ptr Mat4x4; viewport: ptr Vec4; dst: ptr Vec3)      {.importc: "glm_unproject" .}
proc project*(v: ptr Vec3; mat: ptr Mat4x4; viewport: ptr Vec4; dst: ptr Vec3)        {.importc: "glm_project"   .}
proc project_z*(v: ptr Vec3; mat: ptr Mat4x4)                                         {.importc: "glm_project_z" .}
proc pick_matrix*(centre, size: ptr Vec2; viewport: ptr Vec4; dest: ptr Mat4x4)       {.importc: "glm_pickmatrix".}
{.pop.}

{.push inline.}

proc translation*(v3): Mat4x4       = translate_make(result.addr, v3.addr)
proc rotation*(angle; axis): Mat4x4 = rotate_make(result.addr, angle, axis.addr)

proc `*`*(m1, m2): Mat4x4 = mul(m1.addr, m2.addr, result.addr)
proc `*`*(m; v4) : Vec4 = mulv(m.addr, v4.addr, result.addr)
proc `*`*(m; v3) : Vec3 = mulv3(m.addr, v3.addr, 0, result.addr)
proc `*`*(m; s)  : Mat4x4 = scale_uni(m.addr, s)

proc `*=`*(m1: var Mat4x4; m2) = m1 = m1 * m2
proc `*=`*(m : var Mat4x4; s ) = m  = m * s
proc `*=`*(m : var Mat4x4; v3) = scale(m.addr, v3.addr)

proc `+`*(m; v3): Mat4x4 = translate_to(m.addr, v3.addr, result.addr)
proc `+=`*(m: var Mat4x4; v3) = translate(m.addr, v3.addr)

proc scale*(m: var Mat4x4; v3) = scale(m.addr, v3.addr)

proc translate*(m: var Mat4x4; v3)    = translate(m.addr, v3.addr)
proc translate_to*(m: var Mat4x4; v3) = translate_to(m.addr, v3.addr, m.addr)

proc rotate*(m: var Mat4x4; angle; axis) = rotate(m.addr, angle, axis.addr)
proc spin*(m: var Mat4x4; angle; axis)   = spin(m.addr, angle, axis.addr)

proc unprojected*(v: Vec3; mat: Mat4x4; viewport: Vec4): Vec3 =
    unproject v, mat, viewport.addr, result

proc unproject*(v: var Vec3; mat: Mat4x4; viewport: Vec4) =
    let cp = v
    unproject cp, mat, viewport.addr, v

{.pop.}

# TODO
   # CGLM_INLINE void  glm_mat4_ucopy(mat4 mat, mat4 dest);
   # CGLM_INLINE void  glm_mat4_copy(mat4 mat, mat4 dest);
   # CGLM_INLINE void  glm_mat4_identity(mat4 mat);
   # CGLM_INLINE void  glm_mat4_identity_array(mat4 * restrict mat, size_t count);
   # CGLM_INLINE void  glm_mat4_zero(mat4 mat);
   # CGLM_INLINE void  glm_mat4_pick3(mat4 mat, mat3 dest);
   # CGLM_INLINE void  glm_mat4_pick3t(mat4 mat, mat3 dest);
   # CGLM_INLINE void  glm_mat4_ins3(mat3 mat, mat4 dest);
   # CGLM_INLINE void  glm_mat4_mulN(mat4 *matrices[], int len, mat4 dest);
   # CGLM_INLINE float glm_mat4_trace(mat4 m);
   # CGLM_INLINE float glm_mat4_trace3(mat4 m);
   # CGLM_INLINE void  glm_mat4_quat(mat4 m, versor dest) ;
   # CGLM_INLINE void  glm_mat4_transpose_to(mat4 m, mat4 dest);
   # CGLM_INLINE void  glm_mat4_transpose(mat4 m);
   # CGLM_INLINE void  glm_mat4_scale_p(mat4 m, float s);
   # CGLM_INLINE void  glm_mat4_inv_fast(mat4 mat, mat4 dest);
   # CGLM_INLINE void  glm_mat4_swap_col(mat4 mat, int col1, int col2);
   # CGLM_INLINE void  glm_mat4_swap_row(mat4 mat, int row1, int row2);
   # CGLM_INLINE float glm_mat4_rmc(vec4 r, mat4 m, vec4 c);
   # CGLM_INLINE void  glm_mat4_make(float * restrict src, mat4 dest);

   # CGLM_INLINE void glm_rotate_at(mat4 m, vec3 pivot, float angle, vec3 axis);
   # CGLM_INLINE void glm_rotate_atm(mat4 m, vec3 pivot, float angle, vec3 axis);
   # CGLM_INLINE void glm_decompose_scalev(mat4 m, vec3 s);
   # CGLM_INLINE bool glm_uniscaled(mat4 m);
   # CGLM_INLINE void glm_decompose_rs(mat4 m, mat4 r, vec3 s);
   # CGLM_INLINE void glm_decompose(mat4 m, vec4 t, mat4 r, vec3 s);
