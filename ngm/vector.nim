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

type GLMFnKind = enum
    VecVec_Vec
    VecVec_Scalar
    Vec_Scalar
template glm_op_single(name, op, T, ret; kind: GLMFnKind) =
    const glm_str = "glm_" & (to_lower $T) & "_" & (ast_to_str name)
    when kind == VecVec_Vec:
        proc `T name`*(v, u, dest: pointer): ret {.importc: glm_str, header: CGLMHeader.}
        template `op`*(v, u: T): T =
            var result: T
            `T name`(v.addr, u.addr, result.addr)
            result
    elif kind == VecVec_Scalar:
        proc `T name`*(v, u: pointer): ret {.importc: glm_str, header: CGLMHeader.}
        template `op`*(v, u: T): ret =
            `T name`(v.addr, u.addr)
    elif kind == Vec_Scalar:
        proc `T name`*(v: pointer): ret {.importc: glm_str, header: CGLMHeader.}
        template `op`*(v: T): ret =
            `T name` v.addr

template glm_op(name, op, ret, kind) =
    glm_op_single(name, op, Vec2, ret, kind)
    glm_op_single(name, op, Vec3, ret, kind)
    glm_op_single(name, op, Vec4, ret, kind)

template glm_func(name, ret) =
    const
        glm_str_v2 = "glm_" & (to_lower $Vec2) & "_" & (ast_to_str name)
        glm_str_v3 = "glm_" & (to_lower $Vec3) & "_" & (ast_to_str name)
        glm_str_v4 = "glm_" & (to_lower $Vec4) & "_" & (ast_to_str name)
    proc `Vec2 name`*(v: pointer): ret {.importc: glm_str_v2, header: CGLMHeader.}
    proc `Vec3 name`*(v: pointer): ret {.importc: glm_str_v3, header: CGLMHeader.}
    proc `Vec4 name`*(v: pointer): ret {.importc: glm_str_v4, header: CGLMHeader.}
    template name*(v): ret =
        when v is Vec2: `Vec2 name` v.addr
        elif v is Vec3: `Vec3 name` v.addr
        elif v is Vec4: `Vec4 name` v.addr

glm_op(add, `+`, void, VecVec_Vec)
glm_op(sub, `-`, void, VecVec_Vec)
glm_op(mul, `*`, void, VecVec_Vec)
glm_op(vdi, `/`, void, VecVec_Vec)

glm_op(dot, `∙`, float32, VecVec_Scalar) # \bullet

glm_func(norm , float32)
glm_func(norm2, float32)
