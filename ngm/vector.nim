import common
from std/strutils import to_lower

# TODO: https://github.com/stavenko/nim-glm/blob/47d5f8681f3c462b37e37ebc5e7067fa5cba4d16/glm/vec.nim#L193

type
    Vector[N: static int, T] = array[N, T]

    Vec2* = Vector[2, float32]
    Vec3* = Vector[3, float32]
    Vec4* = Vector[4, float32]

func vec*(x, y      : float32): Vec2 = [x, y]
func vec*(x, y, z   : float32): Vec3 = [x, y, z]
func vec*(x, y, z, w: float32): Vec4 = [x, y, z, w]

func `$`*[T](v: Vector[2, T]): string = &"({v[0]}, {v[1]})"
func `$`*[T](v: Vector[3, T]): string = &"({v[0]}, {v[1]}, {v[2]})"
func `$`*[T](v: Vector[4, T]): string = &"({v[0]}, {v[1]}, {v[2]}, {v[3]})"

const
    Vec2Zero* = vec(0, 0)
    Vec3Zero* = vec(0, 0, 0)
    Vec4Zero* = vec(0, 0, 0, 0)

    XAxis* = vec(1, 0, 0)
    YAxis* = vec(0, 1, 0)
    ZAxis* = vec(0, 0, 1)

# type GLMFnKind = enum
#     VecVec_Vec
#     VecVec_Scalar
#     Vec_Scalar
# template glm_op_single(name, op, T, ret; kind: GLMFnKind) =
#     const glm_str = "glm_" & (to_lower $T) & "_" & (ast_to_str name)
#     when kind == VecVec_Vec:
#         proc `T name`*(v, u, dest: pointer): ret {.importc: glm_str, header: CGLMHeader.}
#         template `op`*(v, u: T): T =
#             var result: T
#             `T name`(v.addr, u.addr, result.addr)
#             result
#     elif kind == VecVec_Scalar:
#         proc `T name`*(v, u: pointer): ret {.importc: glm_str, header: CGLMHeader.}
#         template `op`*(v, u: T): ret =
#             `T name`(v.addr, u.addr)
#     elif kind == Vec_Scalar:
#         proc `T name`*(v: pointer): ret {.importc: glm_str, header: CGLMHeader.}
#         template `op`*(v: T): ret =
#             `T name` v.addr

# template glm_op(name, op, ret, kind) =
#     glm_op_single(name, op, Vec2, ret, kind)
#     glm_op_single(name, op, Vec3, ret, kind)
#     glm_op_single(name, op, Vec4, ret, kind)

# template glm_func(name, ret) =
#     const
#         glm_str_v2 = "glm_" & (to_lower $Vec2) & "_" & (ast_to_str name)
#         glm_str_v3 = "glm_" & (to_lower $Vec3) & "_" & (ast_to_str name)
#         glm_str_v4 = "glm_" & (to_lower $Vec4) & "_" & (ast_to_str name)
#     proc `Vec2 name`*(v: pointer): ret {.importc: glm_str_v2, header: CGLMHeader.}
#     proc `Vec3 name`*(v: pointer): ret {.importc: glm_str_v3, header: CGLMHeader.}
#     proc `Vec4 name`*(v: pointer): ret {.importc: glm_str_v4, header: CGLMHeader.}
#     template name*(v): ret =
#         when v is Vec2: `Vec2 name` v.addr
#         elif v is Vec3: `Vec3 name` v.addr
#         elif v is Vec4: `Vec4 name` v.addr

# glm_op(add, `+`, void, VecVec_Vec)
# glm_op(sub, `-`, void, VecVec_Vec)
# glm_op(mul, `*`, void, VecVec_Vec)
# glm_op(vdi, `/`, void, VecVec_Vec)

# glm_op(dot, `∙`, float32, VecVec_Scalar) # \bullet

# glm_func(norm , float32)
# glm_func(norm2, float32)

#[ -------------------------------------------------------------------- ]#

using
    v3p, u3p, dst3: ptr Vec3
    v3 , u3       :     Vec3
    cs            : cfloat
    s             : float32

{.push header: CGLMHeader.}
proc negate*(v3p)          {.importc: "glm_vec3_negate"   .}
proc negate_to*(v3p, dst3) {.importc: "glm_vec3_negate_to".}

proc add*(v3p, u3p, dst3)   {.importc: "glm_vec3_add"  .}
proc sub*(v3p, u3p, dst3)   {.importc: "glm_vec3_sub"  .}
proc scale*(v3p; cs; dst3)  {.importc: "glm_vec3_scale".}

proc cross*(v3p, u3p, dst3)   {.importc: "glm_vec3_cross"       .}
proc normalize*(v3p)          {.importc: "glm_vec3_normalize"   .}
proc normalize_to*(v3p, dst3) {.importc: "glm_vec3_normalize_to".}
{.pop.}

{.push inline.}

proc `-`*(v3): Vec3 = negate_to(v3.addr, result.addr)

proc `+`*(v3, u3): Vec3 = add(v3.addr, u3.addr, result.addr)
proc `-`*(v3, u3): Vec3 = sub(v3.addr, u3.addr, result.addr)

proc `+=`*(v3: var Vec3, u3) = v3 = v3 + u3
proc `-=`*(v3: var Vec3, u3) = v3 = v3 - u3

proc `*`*(v3; s): Vec3 = scale(v3.addr, s, result.addr)
proc `*`*(s; v3): Vec3 = scale(v3.addr, s, result.addr)

proc `*=`*(v3: var Vec3; s) = v3 = v3 * s

proc cross*(v3, u3): Vec3 = cross(v3.addr, u3.addr, result.addr)

proc normalize*(v3: var Vec3)    = normalize v3.addr
proc normalized*(v3: Vec3): Vec3 = normalize_to(v3.addr, result.addr)

{.pop.}

# TODO
 # Functions:
 #   CGLM_INLINE void  glm_vec3(vec4 v4, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_copy(vec3 a, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_zero(vec3 v);
 #   CGLM_INLINE void  glm_vec3_one(vec3 v);
 #   CGLM_INLINE float glm_vec3_dot(vec3 a, vec3 b);
 #   CGLM_INLINE float glm_vec3_norm2(vec3 v);
 #   CGLM_INLINE float glm_vec3_norm(vec3 v);
 #   CGLM_INLINE float glm_vec3_norm_one(vec3 v);
 #   CGLM_INLINE float glm_vec3_norm_inf(vec3 v);
 #   CGLM_INLINE void  glm_vec3_adds(vec3 a, float s, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_subs(vec3 a, float s, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_mul(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_scale_as(vec3 v, float s, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_div(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_divs(vec3 a, float s, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_addadd(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_subadd(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_muladd(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_muladds(vec3 a, float s, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_maxadd(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_minadd(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_subsub(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_addsub(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_mulsub(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_mulsubs(vec3 a, float s, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_maxsub(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_minsub(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_flipsign(vec3 v);
 #   CGLM_INLINE void  glm_vec3_flipsign_to(vec3 v, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_inv(vec3 v);
 #   CGLM_INLINE void  glm_vec3_inv_to(vec3 v, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_crossn(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE float glm_vec3_angle(vec3 a, vec3 b);
 #   CGLM_INLINE void  glm_vec3_rotate(vec3 v, float angle, vec3 axis);
 #   CGLM_INLINE void  glm_vec3_rotate_m4(mat4 m, vec3 v, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_rotate_m3(mat3 m, vec3 v, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_proj(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_center(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE float glm_vec3_distance(vec3 a, vec3 b);
 #   CGLM_INLINE float glm_vec3_distance2(vec3 a, vec3 b);
 #   CGLM_INLINE void  glm_vec3_maxv(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_minv(vec3 a, vec3 b, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_ortho(vec3 v, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_clamp(vec3 v, float minVal, float maxVal);
 #   CGLM_INLINE void  glm_vec3_lerp(vec3 from, vec3 to, float t, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_lerpc(vec3 from, vec3 to, float t, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_mix(vec3 from, vec3 to, float t, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_mixc(vec3 from, vec3 to, float t, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_step_uni(float edge, vec3 x, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_step(vec3 edge, vec3 x, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_smoothstep_uni(float edge0, float edge1, vec3 x, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_smoothstep(vec3 edge0, vec3 edge1, vec3 x, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_smoothinterp(vec3 from, vec3 to, float t, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_smoothinterpc(vec3 from, vec3 to, float t, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_swizzle(vec3 v, int mask, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_make(float * restrict src, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_faceforward(vec3 n, vec3 v, vec3 nref, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_reflect(vec3 v, vec3 n, vec3 dest);
 #   CGLM_INLINE void  glm_vec3_refract(vec3 v, vec3 n, float eta, vec3 dest);

 # Convenient:
 #   CGLM_INLINE void  glm_cross(vec3 a, vec3 b, vec3 d);
 #   CGLM_INLINE float glm_dot(vec3 a, vec3 b);
 #   CGLM_INLINE void  glm_normalize(vec3 v);
 #   CGLM_INLINE void  glm_normalize_to(vec3 v, vec3 dest);
