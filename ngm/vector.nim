# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

{.experimental: "dotOperators".}

import std/[macros, strutils, math, options], common, util
from std/sequtils import map_it, zip

const VectorFields = "xyzw"

type
    Vec2* = array[2, Real]
    Vec3* = array[3, Real]
    Vec4* = array[4, Real]

    AnyVec = Vec2 | Vec3 | Vec4

const
    Vec2Zero* = Vec2 [Real 0, 0]
    Vec3Zero* = Vec3 [Real 0, 0, 0]
    Vec4Zero* = Vec4 [Real 0, 0, 0, 0]

{.push inline.}

func `$`*(v: Vec2): string = &"({v[0]}, {v[1]})"
func `$`*(v: Vec3): string = &"({v[0]}, {v[1]}, {v[2]})"
func `$`*(v: Vec4): string = &"({v[0]}, {v[1]}, {v[2]}, {v[3]})"

func repr*(v: Vec2): string = &"Vec2 (x: {v[0]}, y: {v[1]})"
func repr*(v: Vec3): string = &"Vec3 (x: {v[0]}, y: {v[1]}, z: {v[2]})"
func repr*(v: Vec4): string = &"Vec4 (x: {v[0]}, y: {v[1]}, z: {v[2]}, w: {v[3]})"

func vec2*(x: SomeNumber = 0, y: SomeNumber = 0): Vec2                                       = [Real x, Real y]
func vec3*(x: SomeNumber = 0, y: SomeNumber = 0, z: SomeNumber = 0): Vec3                    = [Real x, Real y, Real z]
func vec4*(x: SomeNumber = 0, y: SomeNumber = 0, z: SomeNumber = 0, w: SomeNumber = 0): Vec4 = [Real x, Real y, Real z, Real w]

func vec*(x: SomeNumber, y: SomeNumber): Vec2                               = vec2 x, y
func vec*(x: SomeNumber, y: SomeNumber, z: SomeNumber): Vec3                = vec3 x, y, z
func vec*(x: SomeNumber, y: SomeNumber, z: SomeNumber, w: SomeNumber): Vec4 = vec4 x, y, z, w

func to_inds(fields: string): seq[int] =
    result = fields.map_it VectorFields.find it
    assert -1 notin result:
        &"\nInvalid swizzle fields for vector: '{fields}'. Valid fields include '{VectorFields}' ({fields} -> {result})"

macro `.`*(v: AnyVec; fields: untyped): untyped =
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

macro `.=`*(v: AnyVec; fields, rhs: untyped): untyped =
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

#[ -------------------------------------------------------------------- ]#

func `==`*(v, u: Vec2): bool = (v.x == u.x) and (v.y == u.y)
func `==`*(v, u: Vec3): bool = (v.x == u.x) and (v.y == u.y) and (v.z == u.z)
func `==`*(v, u: Vec4): bool = (v.x == u.x) and (v.y == u.y) and (v.z == u.z) and (v.w == u.w)

func `=~`*(v, u: Vec2): bool = (v.x =~ u.x) and (v.y =~ u.y)
func `=~`*(v, u: Vec3): bool = (v.x =~ u.x) and (v.y =~ u.y) and (v.z =~ u.z)
func `=~`*(v, u: Vec4): bool = (v.x =~ u.x) and (v.y =~ u.y) and (v.z =~ u.z) and (v.w =~ u.w)

func clamped*(v: Vec2; min, max: SomeNUmber): Vec2 =
    let min = Real min
    let max = Real max
    vec(v.x.clamp(min, max), v.y.clamp(min, max))
func clamped*(v: Vec3; min, max: SomeNUmber): Vec3 =
    let min = Real min
    let max = Real max
    vec(v.x.clamp(min, max), v.y.clamp(min, max), v.z.clamp(min, max))
func clamped*(v: Vec4; min, max: SomeNUmber): Vec4 =
    let min = Real min
    let max = Real max
    vec(v.x.clamp(min, max), v.y.clamp(min, max), v.z.clamp(min, max), v.w.clamp(min, max))
func clamped*(v: Vec2; min, max: Vec2): Vec2 = vec(v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y))
func clamped*(v: Vec3; min, max: Vec3): Vec3 = vec(v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y), v.z.clamp(min.z, max.z))
func clamped*(v: Vec4; min, max: Vec4): Vec4 = vec(v.x.clamp(min.x, max.x), v.y.clamp(min.y, max.y), v.z.clamp(min.z, max.z), v.w.clamp(min.w, max.w))

func clamp*[T: AnyVec](v: var T; min, max: Real) = v = v.clamped(min, max)
func clamp*[T: AnyVec](v: var T; min, max: T)    = v = v.clamped(min, max)

func `-`*(v: Vec2): Vec2 = vec(-v.x, -v.y)
func `-`*(v: Vec3): Vec3 = vec(-v.x, -v.y, -v.z)
func `-`*(v: Vec4): Vec4 = vec(-v.x, -v.y, -v.z, -v.w)

func `+`*(v, u: Vec2): Vec2 = vec(v.x + u.x, v.y + u.y)
func `+`*(v, u: Vec3): Vec3 = vec(v.x + u.x, v.y + u.y, v.z + u.z)
func `+`*(v, u: Vec4): Vec4 = vec(v.x + u.x, v.y + u.y, v.z + u.z, v.w + u.w)
func `+=`*[T: AnyVec](v: var T; u: T) = v = v + u

func `-`*(v, u: Vec2): Vec2 = vec(v.x - u.x, v.y - u.y)
func `-`*(v, u: Vec3): Vec3 = vec(v.x - u.x, v.y - u.y, v.z - u.z)
func `-`*(v, u: Vec4): Vec4 = vec(v.x - u.x, v.y - u.y, v.z - u.z, v.w - u.w)
func `-=`*[T: AnyVec](v: var T; u: T) = v = v - u

func `*`*(v: Vec2; s: SomeNumber): Vec2 = vec(v.x * Real s, v.y * Real s)
func `*`*(v: Vec3; s: SomeNumber): Vec3 = vec(v.x * Real s, v.y * Real s, v.z * Real s)
func `*`*(v: Vec4; s: SomeNumber): Vec4 = vec(v.x * Real s, v.y * Real s, v.z * Real s, v.w * Real s)
func `*`*(s: SomeNumber; v: Vec2): Vec2 = v*s
func `*`*(s: SomeNumber; v: Vec3): Vec3 = v*s
func `*`*(s: SomeNumber; v: Vec4): Vec4 = v*s
func `*=`*[T: AnyVec](v: var T; s: SomeNumber) = v = v * s

func `/`*(v: Vec2; s: SomeNumber): Vec2 = vec(v.x / Real s, v.y / Real s)
func `/`*(v: Vec3; s: SomeNumber): Vec3 = vec(v.x / Real s, v.y / Real s, v.z / Real s)
func `/`*(v: Vec4; s: SomeNumber): Vec4 = vec(v.x / Real s, v.y / Real s, v.z / Real s, v.w / Real s)
func `/=`*[T: AnyVec](v: var T; s: SomeNumber) = v = v / s

# \bullet
func dot*(v, u: Vec2): Real = v.x*u.x + v.y*u.y
func dot*(v, u: Vec3): Real = v.x*u.x + v.y*u.y + v.z*u.z
func dot*(v, u: Vec4): Real = v.x*u.x + v.y*u.y + v.z*u.z + v.w*u.w
func `∙`*(v, u: AnyVec): Real = dot v, u

func norm2*[T: AnyVec](v: T): Real = v∙v
func norm*[T: AnyVec](v: T): Real  = sqrt(norm2 v)
func mag*(v: AnyVec): Real         = norm v

func normalized*[T: AnyVec](v: T): T =
    let mag = mag v
    if mag != 0:
        result = v / mag
func normalize*(v: var AnyVec) = v = normalized v

func distance2*(v, u: Vec2): Real = (v.x - u.x)^2 + (v.y - u.y)^2
func distance2*(v, u: Vec3): Real = (v.x - u.x)^2 + (v.y - u.y)^2 + (v.z - u.z)^2
func distance*(v, u: Vec2 | Vec3): Real = sqrt distance2(v, u)
func `<=>`*(v, u: Vec2 | Vec3): Real = distance2 v, u
func `<->`*(v, u: Vec2 | Vec3): Real = distance  v, u

func angle*(v, u: Vec2 | Vec3): Radians =
    arccos((v ∙ u) / (v.mag * u.mag))

func cross*(v, u: Vec3): Vec3 =
    vec(v.y*u.z - v.z*u.y,
        v.z*u.x - v.x*u.z,
        v.x*u.y - v.y*u.x)
func `×`*(v, u: Vec3): Vec3 = cross v, u

func rotated*(v: Vec2; α: Radians): Vec2 =
    ## Rotates CCW
    let cosa = cos float32 α
    let sina = sin float32 α
    vec(cosa*v.x - sina*v.y, sina*v.x + cosa*v.y)

func rotated*(v: Vec3; α: Radians; axis: Vec3): Vec3 =
    ## Rodrigues' rotation formula
    ## `v = v*cos(α) + (k×v)sin(α) + k*(k∙v)(1 - cos(α))`
    ## where `k` is the axis of rotation
    ## Axis should already be normalized
    ngm_assert (axis.mag =~ 1.0), "Axis should be normalized before rotation"

    let cosa = cos float32 α
    let sina = sin float32 α
    v*cosa + (axis × v)*sina + axis*(axis ∙ v)*(1 - cosa)

func rotate*(v: var Vec2; α: Radians): Vec2             = v = rotated(v, α)
func rotate*(v: var Vec3; α: Radians; axis: Vec3): Vec3 = v = rotated(v, α, axis)

func reflected*[T: Vec2 | Vec3](v, n: T): T   = v - 2*(v∙n)*n
func reflect*[T: Vec2 | Vec3](v: var T; n: T) = v = reflected(v, n)

func refracted*[T: Vec2 | Vec3](v, n: T; μ: Real): Option[T] =
    ## Normal should already be normlized
    ngm_assert (n.mag =~ 1), "Normal should be normalized before refraction"

    let dp = n∙v
    let k  = 1 - (μ^2)*(1 - dp^2)
    if k < 0:
        return none[T]
    some (sqrt(k)*n + μ*(v - dp*n))

func refract*[T: Vec2 | Vec3](v: var T; n: T; μ: Real): bool =
    let r = refracted(v, n, μ)
    result = r.is_some
    v = if result: get r else: vec3()

{.pop.}
