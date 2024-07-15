# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

{.experimental: "dotOperators".}
{.emit: """
#define glm_vec2_muls(a, b, d) glm_vec2_scale(a, b, d)
#define glm_vec3_muls(a, b, d) glm_vec3_scale(a, b, d)
#define glm_vec4_muls(a, b, d) glm_vec4_scale(a, b, d)
""".}

import std/[macros, strutils], common
from std/sequtils  import map_it, zip

const VectorFields = "xyzw"

type
    Vector[N: static int, T] = array[N, T]

    Vec2* = Vector[2, float32]
    Vec3* = Vector[3, float32]
    Vec4* = Vector[4, float32]

func vec*(x, y      : float32): Vec2 = [x, y]
func vec*(x, y, z   : float32): Vec3 = [x, y, z]
func vec*(x, y, z, w: float32): Vec4 = [x, y, z, w]

func `$`*(v: Vec2): string = &"({v[0]}, {v[1]})"
func `$`*(v: Vec3): string = &"({v[0]}, {v[1]}, {v[2]})"
func `$`*(v: Vec4): string = &"({v[0]}, {v[1]}, {v[2]}, {v[3]})"

converter `Vec2 -> ptr Vec2`*(v: Vec2): ptr Vec2 = v.addr
converter `Vec3 -> ptr Vec3`*(v: Vec3): ptr Vec3 = v.addr
converter `Vec4 -> ptr Vec4`*(v: Vec4): ptr Vec4 = v.addr

func to_inds(fields: string): seq[int] =
    result = fields.map_it VectorFields.find it
    assert -1 notin result:
        &"Invalid swizzle fields for vector: '{fields}'. Valid fields include '{VectorFields}' ({fields} -> {result})"

macro `.`*(v: Vector; fields: untyped): untyped =
    let inds = to_inds fields.repr
    if inds.len == 1:
        let i = inds[0]
        result = quote do:
            `v`[`i`]
    else:
        result = new_nim_node nnkCall
        result.add ident "vec"
        for i in inds:
            result.add quote do:
                `v`[`i`]

macro `.=`*(v: Vector; fields, rhs: untyped): untyped =
    let (lhs_count, lhs_inds) = (fields.repr.len, to_inds fields.repr)
    let (rhs_count, rhs_inds) = case rhs.kind
        of nnkIntLit, nnkFloatLit    : (1, @[])
        of nnkTupleConstr, nnkBracket: (rhs.len, to_inds fields.repr)
        of nnkDotExpr                : (rhs[1].repr.len, to_inds rhs[1].repr)
        else:
            echo &"Invalid node kind for RHS of vector `.=`: '{rhs.kind}'"
            quit 1
    assert lhs_count == rhs_count:
        &"Mismatched field count for vector `.=`: {lhs_count} LHS != {rhs_count} RHS"

    if lhs_count == 1:
        let i = lhs_inds[0]
        result = quote do:
            `v`[`i`] = `rhs`
    else:
        result = new_nim_node nnkStmtList
        let internal_type = v.get_type[2]
        let is_dot_expr = rhs.kind == nnkDotExpr
        # Need to make a copy for swapping fields if LHS symbol = RHS symbol
        let rhs =
            if is_dot_expr and (v.repr == rhs[0].repr):
                let cp = gen_sym(ident = v.repr)
                result.add quote do:
                    let `cp` = `v`
                cp
            else:
                rhs[0]
        for (i, j) in zip(lhs_inds, rhs_inds):
            if is_dot_expr:
                result.add quote do:
                    `v`[`i`] = `internal_type`(`rhs`[`j`])
            else:
                let rhs = rhs[j]
                result.add quote do:
                    `v`[`i`] = `internal_type`(`rhs`)

const
    Vec2Zero* = vec(0, 0)
    Vec3Zero* = vec(0, 0, 0)
    Vec4Zero* = vec(0, 0, 0, 0)

    XAxis* = vec(1, 0, 0)
    YAxis* = vec(0, 1, 0)
    ZAxis* = vec(0, 0, 1)

#[ -------------------------------------------------------------------- ]#

macro gen_fns(fn_name, op: untyped; is_infix = true; is_calc = false): untyped =
    result = new_nim_node nnkStmtList
    let is_infix = is_infix == (new_lit true)
    let is_calc  = is_calc  == (new_lit true) # Calculations return a scalar value like the dot product
    for n in 2..4:
        let
            name     = "glm_vec$1_$2"  % [$n, $fn_name]
            name_s   = "glm_vec$1_$2s" % [$n, $fn_name]
            ident    = ident name
            idents   = ident name_s
            header   = CGLMDir / ("vec$1.h" % $n)
            vec_t    = ident ("Vec$1" % $n)
            scalar_t = ident "float32"
        if is_calc:
            result.add quote do:
                proc `ident`* (v, u: ptr `vec_t`): `scalar_t` {.header: `header`, importc: `name`.}
                func `fn_name`*(v, u: `vec_t`): `scalar_t` {.inline.} = `ident`(v, u)
                func `op`*(v, u: `vec_t`): `scalar_t`      {.inline.} = `ident`(v, u)
        elif is_infix:
            let eq_op = ident ($op & "=")
            result.add quote do:
                proc `ident`* (v, u, dst: ptr `vec_t`)                          {.header: `header`, importc: `name`  .}
                proc `idents`*(v: ptr `vec_t`; s: `scalar_t`; dst: ptr `vec_t`) {.header: `header`, importc: `name_s`.}
                func `fn_name`*(v, u: `vec_t`): `vec_t`             {.inline.} = `ident`(v, u, result)
                func `fn_name`*(v: `vec_t`; s: `scalar_t`): `vec_t` {.inline.} = `idents`(v, s, result)
                func `op`*(v, u: `vec_t`): `vec_t`                  {.inline.} = `ident`(v, u, result)
                func `op`*(v: `vec_t`; s: `scalar_t`): `vec_t`      {.inline.} = `idents`(v, s, result)
                func `eq_op`*(v: var `vec_t`; u: `vec_t`)           {.inline.} = v = `op`(v, u)
                func `eq_op`*(v: var `vec_t`; s: `scalar_t`)        {.inline.} = v = `op`(v, s)
        else:
            if ($name).ends_with "_to":
                result.add quote do:
                    proc `ident`*(v, dst: ptr `vec_t`) {.header: `header`, importc: `name`.}
                    func `op`*(v: `vec_t`): `vec_t` {.inline.} = `ident`(v, result)
            else:
                result.add quote do:
                    proc `ident`*(v: ptr `vec_t`) {.header: `header`, importc: `name`.}
                    func `op`*(v: var `vec_t`) {.inline.} = `ident`(v)

{.emit: CGLMInclude.}
gen_fns negate      , `-`       , is_infix = false
gen_fns normalize   , normalize , is_infix = false
gen_fns normalize_to, normalized, is_infix = false

gen_fns add  , `+`
gen_fns sub  , `-`
gen_fns mul  , `*`
gen_fns `div`, `/`

gen_fns dot      , `∙`  , is_calc = true
gen_fns distance , `<->`, is_calc = true
gen_fns distance2, `<=>`, is_calc = true

proc cross*(v, u, dst: ptr Vec3) {.header: CGLMDir / "vec3.h", importc: "glm_vec3_cross".}
func cross*(v, u: Vec3): Vec3 {.inline.} = cross v, u, result
func `×`*  (v, u: Vec3): Vec3 {.inline.} = cross v, u, result

