# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import std/[macros, enumerate, options, math], common, vector
from std/strutils import join, `%`

type
    AMat2*[T] = array[2, AVec2[T]]
    AMat3*[T] = array[3, AVec3[T]]
    AMat4*[T] = array[4, AVec4[T]]

    Mat2F32* = AMat2[float32]
    Mat3F32* = AMat3[float32]
    Mat4F32* = AMat4[float32]
    Mat2F64* = AMat2[float64]
    Mat3F64* = AMat3[float64]
    Mat4F64* = AMat4[float64]

    Mat2* = Mat2F32
    Mat3* = Mat3F32
    Mat4* = Mat4F32

    AMat* = AMat2 | AMat3 | AMat4

const
    Mat2Ident*: Mat2 = [[1, 0],
                        [0, 1]]
    Mat3Ident*: Mat3 = [[1, 0, 0],
                        [0, 1, 0],
                        [0, 0, 1]]
    Mat4Ident*: Mat4 = [[1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [0, 0, 0, 1]]

{.push inline.}

func `$`*(m: AMat): string = "[" & (m.join ",\n ") & "]"

func `[]`*(m: AMat; j, i: int): float32         = m[j][i]
func `[]`*(m: var AMat; j, i: int): var float32 = m[j][i]
func `[]=`*(m: var AMat; j, i: int; s: float32) = m[j][i] = s

func mat*(v1, v2: Vec2): Mat2         = [v1, v2]
func mat*(v1, v2, v3: Vec3): Mat3     = [v1, v2, v3]
func mat*(v1, v2, v3, v4: Vec4): Mat4 = [v1, v2, v3, v4]

func mat3*(m: Mat4): Mat3 = [m[0].xyz, m[1].xyz, m[2].xyz]

func matrix_size(T: string): (int, int) {.compileTime.} =
    case T
    of $Mat2: (2, 2)
    of $Mat3: (3, 3)
    of $Mat4: (4, 4)
    else:
        do_assert false, T
        (0, 0)

macro expand_alias*(m: AMat): untyped =
    result = new_nim_node nnkStmtList
    let (w, h) = matrix_size $(get_type_inst m)
    for n in 0..<w*h:
        let j = n div w
        let i = n mod w
        let name = ident ("$1$2$3" % [repr m, $j, $i])
        result.add quote do:
            let `name` = `m`[`j`, `i`]

macro gen_accessors*(T: typedesc; accs: varargs[string]): untyped =
    result = new_nim_node nnkStmtList
    let (w, _) = matrix_size $T
    for (n, acc) in enumerate accs:
        let name    = ident $acc
        let name_eq = ident ($acc & "=")
        let j = n div w
        let i = n mod w
        result.add quote("@@") do:
            func `@@name`*(m: `@@T`): float32 = m[@@j, @@i]
            func `@@name_eq`*(m: var `@@T`; s: float32) = m[@@j, @@i] = s

Mat2.gen_accessors("m00", "m01",
                   "m10", "m11")
Mat3.gen_accessors("m00", "m01", "m02",
                   "m10", "m11", "m12",
                   "m20", "m21", "m22")
Mat4.gen_accessors("m00", "m01", "m02", "m03",
                   "m10", "m11", "m12", "m13",
                   "m20", "m21", "m22", "m23",
                   "m30", "m31", "m32", "m33")

#[ -------------------------------------------------------------------- ]#

func mat3*(v1, v2, v3: Vec3): Mat3     = [v1, v2, v3]
func mat4*(v1, v2, v3, v4: Vec4): Mat4 = [v1, v2, v3, v4]

func `==`*(m1, m2: AMat): bool =
    for i in 0..<m1.len:
        if m1[i] != m2[i]:
            return false
    return true
func `=~`*(m1, m2: AMat): bool =
    for i in 0..<m1.len:
        if not (m1[i] =~ m2[i]):
            return false
    return true

func `-`*[T: AMat](m: T): T =
    for i in 0..<m.len:
        result[i] = -m[i]

func `+`*[T: AMat](m1, m2: T): T {.noInit.} =
    for i in 0..<m1.len:
        result[i] = m1[i] + m2[i]
func `+=`*[T: AMat](m1: var T; m2: T) = m1 = m1 + m2

func `-`*[T: AMat](m1, m2: T): T {.noInit.} =
    for i in 0..<m1.len:
        result[i] = m1[i] - m2[i]
func `-=`*[T: AMat](m1: var T; m2: T) = m1 = m1 - m2

func `*`*[T: AMat](m: T; s: float32): T {.noInit.} =
    for i in 0..<m.len:
        result[i] = s*m[i]
func `*`*[T: AMat](s: float32; m: T): T = m * s
func `*=`*(m: var AMat; s: float32) = m = m * s

func `/`*[T: AMat](m: T; s: float32): T {.noInit.} =
    for i in 0..<m.len:
        result[i] = m[i]/s
func `/`*[T: AMat](s: float32; m: T): T = m / s
func `/=`*(m: var AMat; s: float32) = m = m / s

func scaled*[T: AMat](m: T; s: float32): T =
    result = m
    for i in 0..<m.len:
        result[i, i] *= s
func scale*[T: AMat](m: var T; s: float32) = m = m.scaled s

func transposed*(m: Mat2): Mat2 =
    expand_alias m
    [[m00, m10],
     [m01, m11]]

func transposed*(m: Mat3): Mat3 =
    expand_alias m
    [[m00, m10, m20],
     [m01, m11, m21],
     [m02, m12, m22]]

func transposed*(m: Mat4): Mat4 =
    expand_alias m
    [[m00, m10, m20, m30],
     [m01, m11, m21, m31],
     [m02, m12, m22, m32],
     [m03, m13, m23, m33]]

func transpose*(m: var (Mat2 | Mat3 | Mat4)) = m = transposed m

func determinant*(m: Mat2): float32 =
    expand_alias m
    m00*m11 - m01*m10

func determinant*(m: Mat3): float32 =
    expand_alias m
    m00*(m11*m22 - m12*m21) -
    m01*(m10*m22 - m12*m20) +
    m02*(m10*m21 - m11*m20)

func determinant*(m: Mat4): float32 =
    expand_alias m
    let
        t0 = m22*m33 - m23*m32
        t1 = m21*m33 - m23*m31
        t2 = m21*m32 - m22*m31
        t3 = m20*m32 - m22*m30
        t4 = m20*m33 - m23*m30
        t5 = m20*m31 - m21*m30
    m00*(m11*t0 - m12*t1 + m13*t2) -
    m01*(m10*t0 - m12*t4 + m13*t3) +
    m02*(m10*t1 - m11*t4 + m13*t5) -
    m03*(m10*t2 - m11*t3 + m12*t5)

func det*(m: AMat): float32 = determinant m

func inverse*(m: Mat2): Option[Mat2] =
    let det = det m
    if det == 0:
        return none Mat2

    expand_alias m
    some (1 / det)*[[ m11, -m01],
                    [-m10,  m00]]

func inverse*(m: Mat3): Option[Mat3] =
    let det = det m
    if det == 0:
        return none Mat3

    expand_alias m
    some (1 / det)*[[m11*m22 - m12*m21, m02*m21 - m01*m22, m01*m12 - m02*m11],
                    [m12*m20 - m10*m22, m00*m22 - m02*m20, m02*m10 - m00*m12],
                    [m10*m21 - m11*m20, m01*m20 - m00*m21, m00*m11 - m01*m10]]

func inverse*(m: Mat4): Option[Mat4] =
    let det = det m
    if det == 0:
        return none Mat4

    expand_alias m
    let
        t00 = m00*m11 - m01*m10
        t01 = m00*m12 - m02*m10
        t02 = m00*m13 - m03*m10
        t03 = m01*m12 - m02*m11
        t04 = m01*m13 - m03*m11
        t05 = m02*m13 - m03*m12
        t06 = m20*m31 - m21*m30
        t07 = m20*m32 - m22*m30
        t08 = m20*m33 - m23*m30
        t09 = m21*m32 - m22*m31
        t10 = m21*m33 - m23*m31
        t11 = m22*m33 - m23*m32

    let det_inv = 1 / det
    some det_inv*[[ m11*t11 - m12*t10 + m13*t09, -m01*t11 + m02*t10 - m03*t09,  m31*t05 - m32*t04 + m33*t03, -m21*t05 + m22*t04 - m23*t03],
                  [-m10*t11 + m12*t08 - m13*t07,  m00*t11 - m02*t08 + m03*t07, -m30*t05 + m32*t02 - m33*t01,  m20*t05 - m22*t02 + m23*t01],
                  [ m10*t10 - m11*t08 + m13*t06, -m00*t10 + m01*t08 - m03*t06,  m30*t04 - m31*t02 + m33*t00, -m20*t04 + m21*t02 - m23*t00],
                  [-m10*t09 + m11*t07 - m12*t06,  m00*t09 - m01*t07 + m02*t06, -m30*t03 + m31*t01 - m32*t00,  m20*t03 - m21*t01 + m22*t00]]

func inv*(m: Mat2): Option[Mat2] = inverse m
func inv*(m: Mat3): Option[Mat3] = inverse m
func inv*(m: Mat4): Option[Mat4] = inverse m

func `*`*(a, b: Mat2): Mat2 =
    expand_alias a
    expand_alias b
    [[a00*b00 + a10*b01, a01*b00 + a11*b01],
     [a00*b10 + a10*b11, a01*b10 + a11*b11]]

func `*`*(a, b: Mat3): Mat3 =
    expand_alias a
    expand_alias b
    [[a00*b00 + a10*b01 + a20*b02, a01*b00 + a11*b01 + a21*b02, a02*b00 + a12*b01 + a22*b02],
     [a00*b10 + a10*b11 + a20*b12, a01*b10 + a11*b11 + a21*b12, a02*b10 + a12*b11 + a22*b12],
     [a00*b20 + a10*b21 + a20*b22, a01*b20 + a11*b21 + a21*b22, a02*b20 + a12*b21 + a22*b22]]

func `*`*(a, b: Mat4): Mat4 =
    expand_alias a
    expand_alias b
    [[a00*b00 + a10*b01 + a20*b02 + a30*b03, a01*b00 + a11*b01 + a21*b02 + a31*b03, a02*b00 + a12*b01 + a22*b02 + a32*b03, a03*b00 + a13*b01 + a23*b02 + a33*b03],
     [a00*b10 + a10*b11 + a20*b12 + a30*b13, a01*b10 + a11*b11 + a21*b12 + a31*b13, a02*b10 + a12*b11 + a22*b12 + a32*b13, a03*b10 + a13*b11 + a23*b12 + a33*b13],
     [a00*b20 + a10*b21 + a20*b22 + a30*b23, a01*b20 + a11*b21 + a21*b22 + a31*b23, a02*b20 + a12*b21 + a22*b22 + a32*b23, a03*b20 + a13*b21 + a23*b22 + a33*b23],
     [a00*b30 + a10*b31 + a20*b32 + a30*b33, a01*b30 + a11*b31 + a21*b32 + a31*b33, a02*b30 + a12*b31 + a22*b32 + a32*b33, a03*b30 + a13*b31 + a23*b32 + a33*b33]]

func `*`*(m: Mat2; v: Vec2): Vec2 =
    expand_alias m
    [m00*v.x + m10*v.y,
     m01*v.x + m11*v.y]

func `*`*(m: Mat3; v: Vec3): Vec3 =
    expand_alias m
    [m00*v.x + m10*v.y + m20*v.z,
     m01*v.x + m11*v.y + m21*v.z,
     m02*v.x + m12*v.y + m22*v.z]

func `*`*(m: Mat4; v: Vec4): Vec4 =
    expand_alias m
    [m00*v.x + m10*v.y + m20*v.z + m30*v.w,
     m01*v.x + m11*v.y + m21*v.z + m31*v.w,
     m02*v.x + m12*v.y + m22*v.z + m32*v.w,
     m03*v.x + m13*v.y + m23*v.z + m33*v.w]

func `*`*(m: Mat4; v: Vec3): Vec3 =
    expand_alias m
    [m00*v.x + m10*v.y + m20*v.z,
     m01*v.x + m11*v.y + m21*v.z,
     m02*v.x + m12*v.y + m22*v.z]

func translation*(v: Vec2): Mat3 =
    [[1.0, 0.0, 0.0],
     [0.0, 1.0, 0.0],
     [v.x, v.y, 1.0]]

func translation*(v: Vec3): Mat4 =
    [[1.0, 0.0, 0.0, 0.0],
     [0.0, 1.0, 0.0, 0.0],
     [0.0, 0.0, 1.0, 0.0],
     [v.x, v.y, v.z, 1.0]]

func translate*(m: var Mat3; v: Vec2) =
    expand_alias m
    m.m02 = m00*v.x + m10*v.y + m02
    m.m12 = m01*v.x + m11*v.y + m12

func translate*(m: var Mat4; v: Vec3) =
    expand_alias m
    m.m03 = m00*v.x + m10*v.y + m20*v.z + m03
    m.m13 = m01*v.x + m11*v.y + m21*v.z + m13
    m.m23 = m02*v.x + m12*v.y + m22*v.z + m23

func translated*(m: Mat3; v: Vec2): Mat3 = result = m; result.translate v
func translated*(m: Mat4; v: Vec3): Mat4 = result = m; result.translate v

func dilation*(v: Vec2): Mat3 =
    [[v.x, 0.0, 0.0],
     [0.0, v.y, 0.0],
     [0.0, 0.0, 1.0]]

func dilation*(v: Vec3): Mat4 =
    [[v.x, 0.0, 0.0, 0.0],
     [0.0, v.y, 0.0, 0.0],
     [0.0, 0.0, v.z, 0.0],
     [0.0, 0.0, 0.0, 1.0]]

func scale*(m: var Mat3; v: Vec2) =
    expand_alias m
    m.m00 = m00*v.x
    m.m01 = m01*v.x
    m.m02 = m02*v.x

    m.m10 = m10*v.y
    m.m11 = m11*v.y
    m.m12 = m12*v.y

func scale*(m: var Mat4; v: Vec3) =
    expand_alias m
    m.m00 = m00*v.x
    m.m01 = m01*v.x
    m.m02 = m02*v.x
    m.m03 = m03*v.x

    m.m10 = m10*v.y
    m.m11 = m11*v.y
    m.m12 = m12*v.y
    m.m13 = m13*v.y

    m.m20 = m20*v.z
    m.m21 = m21*v.z
    m.m22 = m22*v.z
    m.m23 = m23*v.z

func scaled*(m: Mat3; v: Vec2): Mat3 = result = m; result.scale v
func scaled*(m: Mat4; v: Vec3): Mat4 = result = m; result.scale v

func rotation*(α: float32; v: Vec3): Mat4 =
    ## CCW rotation
    ## Axis vector needs to be normalized before rotation
    ngm_assert (v.mag =~ 1), "Axis vector should be normalized before rotation"

    let c  = cos α
    let s  = sin α
    let ci = 1 - c
    [[v.x*v.x*ci + c    , v.x*v.y*ci - v.z*s, v.x*v.z*ci + v.y*s, 0],
     [v.y*v.x*ci + v.z*s, v.y*v.y*ci + c    , v.y*v.z*ci - v.x*s, 0],
     [v.z*v.x*ci - v.y*s, v.z*v.y*ci + v.x*s, v.z*v.z*ci + c    , 0],
     [0                 , 0                 , 0                 , 1]]

func x_rotation*(α: float32): Mat4 =
    let c = cos α
    let s = sin α
    [[1, 0,  0, 0],
     [0, c, -s, 0],
     [0, s,  c, 0],
     [0, 0,  0, 1]]

func y_rotation*(α: float32): Mat4 =
    let c = cos α
    let s = sin α
    [[ c, 0, s, 0],
     [ 0, 1, 0, 0],
     [-s, 0, c, 0],
     [ 0, 0, 0, 1]]

func z_rotation*(α: float32): Mat4 =
    let c = cos α
    let s = sin α
    [[c, -s, 0, 0],
     [s,  c, 0, 0],
     [0,  0, 1, 0],
     [0,  0, 0, 1]]

{.pop.}
