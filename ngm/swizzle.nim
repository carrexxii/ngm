# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

{.experimental: "dotOperators".}

import std/macros, common
from std/sequtils import map_it, zip

func to_inds(fields: string): seq[int] =
    for f in VectorFields:
        result = fields.map_it f.find it
        if -1 notin result:
            return result

    error &"Invalid swizzle fields for vector: '{fields}'. Valid fields include '{VectorFields}'"

macro `.`*(v: Swizzleable; fields: untyped): untyped =
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

# TODO: nnkIfExpr, nnkCall
macro `.=`*(v: Swizzleable; fields, rhs: untyped): untyped =
    let (lhs_count, lhs_inds) = (fields.repr.len, to_inds fields.repr)
    let (rhs_count, rhs_inds) = case rhs.kind
        of nnkIntLit, nnkFloatLit    : (1, @[])
        of nnkTupleConstr, nnkBracket: (rhs.len, to_inds fields.repr)
        of nnkDotExpr                : (rhs[1].repr.len, to_inds rhs[1].repr)
        else:
            error &"Invalid node kind for RHS of vector `.=`: '{rhs.kind}'"
    if lhs_count != rhs_count:
        error &"Mismatched field count for vector `.=`: {lhs_count} LHS != {rhs_count} RHS"

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
