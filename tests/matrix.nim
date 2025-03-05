{.push header: "../lib/cglm/include/cglm/cglm.h".}
proc cglm_mat2_mul(a, b, dst: pointer)  {.importc: "glm_mat2_mul" .}
proc cglm_mat2_mulv(a, v, dst: pointer) {.importc: "glm_mat2_mulv".}
proc cglm_mat3_mul(a, b, dst: pointer)  {.importc: "glm_mat3_mul" .}
proc cglm_mat3_mulv(a, v, dst: pointer) {.importc: "glm_mat3_mulv".}
proc cglm_mat4_mul(a, b, dst: pointer)  {.importc: "glm_mat4_mul" .}
proc cglm_mat4_mulv(a, v, dst: pointer) {.importc: "glm_mat4_mulv".}

proc cglm_mat2_inv(a, dst: pointer) {.importc: "glm_mat2_inv".}
proc cglm_mat3_inv(a, dst: pointer) {.importc: "glm_mat3_inv".}
proc cglm_mat4_inv(a, dst: pointer) {.importc: "glm_mat4_inv".}

proc cglm_mat4_mulv3(a, v: pointer; v4: cfloat; dst: pointer) {.importc: "glm_mat4_mulv3".}
{.pop.}

let
    a = Mat2Ident
    b = Mat3Ident
    c = Mat4Ident
    d: Mat2 = [[2, 1],
               [4, 3]]
    e: Mat3 = [[2, 1, 0],
               [4, 3, 2],
               [1, 0, 1]]
    f = mat3(vec(1, 0, 0), vec(2, 1, 0), vec(2, -1, 0))
    g = mat4(vec(1, 0, 0, 0), vec(0, 1, -1, 0), vec(-1, 0, 1, 0), vec(-1, -1, 1, 0))

test "Stringify":
    check:
        $a == "[[1.0, 0.0],\n [0.0, 1.0]]"
        $b == "[[1.0, 0.0, 0.0],\n [0.0, 1.0, 0.0],\n [0.0, 0.0, 1.0]]"
        $c == "[[1.0, 0.0, 0.0, 0.0],\n [0.0, 1.0, 0.0, 0.0],\n [0.0, 0.0, 1.0, 0.0],\n [0.0, 0.0, 0.0, 1.0]]"

        $f == "[[1.0, 0.0, 0.0],\n [2.0, 1.0, 0.0],\n [2.0, -1.0, 0.0]]"

test "Basics":
    check:
        (2 * sizeof Vec2) == sizeof Mat2
        (3 * sizeof Vec3) == sizeof Mat3
        (4 * sizeof Vec4) == sizeof Mat4
        (3 * sizeof Vec3) == sizeof Mat3
        (4 * sizeof Vec4) == sizeof Mat4

    check:
        a[0, 0] =~ 1
        b[1, 0] =~ 0
        c[3, 3] =~ 1
        d[1, 0] =~ 4
        e[1, 2] =~ 2

    check:
        a.m00 == 1
        b.m01 == 0
        c.m32 == 0

    let `a + d`: Mat2 = [[3, 1], [4, 4]]
    let `b + e`: Mat3 = [[3, 1, 0], [4, 4, 2], [1, 0, 2]]
    check:
        `a + d` =~ a + d
        `b + e` =~ b + e

    let `a - d`: Mat2 = [[-1, -1], [-4, -2]]
    let `b - e`: Mat3 = [[-1, -1, 0], [-4, -2, -2], [-1, 0, 0]]
    check:
        `a - d` =~ a - d
        `b - e` =~ b - e

    let `3 * c`: Mat4 = [[3, 0, 0, 0], [0, 3, 0, 0], [0, 0, 3, 0], [0, 0, 0, 3]]
    let `2 * f`: Mat3 = [[2, 0, 0], [4, 2, 0], [4, -2, 0]]
    check:
        `3 * c` =~ 3*c
        `2 * f` == 2*f

test "Transforming":
    let scaled_2d: Mat2 = [[4, 1], [4, 6]]
    let scaled_3e: Mat3 = [[6, 1, 0], [4, 9, 2], [1, 0, 3]]
    check:
        scaled_2d =~ d.scaled 2
        scaled_3e =~ e.scaled 3

test "Mat2 Multiply":
    var a: Mat2 = [[1, 2],
                   [5, 6]]
    var b: Mat2 = [[2, 4],
                   [1, 3]]
    var v: Vec2 = [1, 2]
    var u: Vec2 = [-2, 4]

    var dstm: Mat2
    var dstv: Vec2
    cglm_mat2_mul a.addr, b.addr, dstm.addr
    check dstm =~ a*b
    cglm_mat2_mul b.addr, a.addr, dstm.addr
    check dstm =~ b*a

    cglm_mat2_mulv a.addr, v.addr, dstv.addr
    check dstv =~ a*v

    cglm_mat2_mulv b.addr, v.addr, dstv.addr
    check dstv =~ b*v

test "Mat3 Multiply":
    var a: Mat3 = [[1, 2, 3],
                   [5, 6, 7],
                   [9, 0, 1]]
    var b: Mat3 = [[2, 4, 6],
                   [1, 3, 5],
                   [0, 3, 6]]
    var v: Vec3 = [1, 2, 3]
    var u: Vec3 = [-2, 4, -6]

    var dstm: Mat3
    var dstv: Vec3
    cglm_mat3_mul a.addr, b.addr, dstm.addr
    check dstm =~ a*b
    cglm_mat3_mul b.addr, a.addr, dstm.addr
    check dstm =~ b*a

    cglm_mat3_mulv a.addr, v.addr, dstv.addr
    check dstv =~ a*v

    cglm_mat3_mulv b.addr, v.addr, dstv.addr
    check dstv =~ b*v

test "Mat4 Multiply":
    var a: Mat4 = [[1, 2, 3, 4],
                   [5, 6, 7, 8],
                   [9, 0, 1, 2],
                   [3, 4, 5, 6]]
    var b: Mat4 = [[2, 4, 6, 8],
                   [1, 3, 5, 7],
                   [0, 3, 6, 9],
                   [1, 1, 1, 1]]
    var v: Vec4 = [1, 2, 3, 4]
    var u: Vec4 = [-2, 4, -6, 8]

    var dstm: Mat4
    var dstv: Vec4
    cglm_mat4_mul a.addr, b.addr, dstm.addr
    check dstm =~ a*b
    cglm_mat4_mul b.addr, a.addr, dstm.addr
    check dstm =~ b*a

    cglm_mat4_mulv a.addr, v.addr, dstv.addr
    check dstv =~ a*v
    cglm_mat4_mulv b.addr, v.addr, dstv.addr
    check dstv =~ b*v

    var dstv3: Vec3
    let v3 = v.xyz
    let u3 = u.xyz
    cglm_mat4_mulv3 a.addr, v3.addr, 0, dstv3.addr
    check dstv3 =~ a*v3
    cglm_mat4_mulv3 a.addr, u3.addr, 0, dstv3.addr
    check dstv3 =~ a*u3

    cglm_mat4_mulv3 b.addr, v3.addr, 0, dstv3.addr
    check dstv3 =~ b*v3
    cglm_mat4_mulv3 b.addr, u3.addr, 0, dstv3.addr
    check dstv3 =~ b*u3

test "Inverse":
    var a: Mat2 = [[1, 2],
                   [5, 6]]
    var b: Mat2 = [[2, 4],
                   [1, 3]]
    var c: Mat3 = [[1, 2, 3],
                   [5, 6, 7],
                   [9, 0, 1]]
    var d: Mat3 = [[2, 4, 6],
                   [1, 3, 5],
                   [0, 3, 6]]
    var e: Mat4 = [[1, 2, 3, 4],
                   [5, 6, 7, 8],
                   [9, 0, 1, 2],
                   [3, 4, 5, 6]]
    var f: Mat4 = [[2, 4, 6, 8],
                   [1, 3, 5, 7],
                   [0, 3, 6, 9],
                   [1, 1, 1, 1]]

    var dst2: Mat2
    cglm_mat2_inv a.addr, dst2.addr
    check (some dst2) == inv a
    cglm_mat2_inv b.addr, dst2.addr
    check (some dst2) == inv b

    var dst3: Mat3
    cglm_mat3_inv c.addr, dst3.addr
    check (some dst3) == inv c
    cglm_mat3_inv d.addr, dst3.addr
    check (none Mat3) == inv d
    check dst3.m00 =~ Inf

    var dst4: Mat4
    cglm_mat4_inv e.addr, dst4.addr
    check (none Mat4) == inv e
    check is_nan dst4.m00
    cglm_mat4_inv f.addr, dst4.addr
    check (none Mat4) == inv f
    check is_nan dst4.m00

    var g: Mat4 = [[1, 1, 0, 1],
                   [2, 1, 5, 2],
                   [0, 1, 1, 3],
                   [0, 0, 0, 1]]
    cglm_mat4_inv g.addr, dst4.addr
    check (some dst4) == inv g
