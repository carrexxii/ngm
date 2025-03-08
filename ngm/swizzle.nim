# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

{.experimental: "dotOperators".}

import std/[macros, enumerate, sequtils], common

func to_inds(fields: string): seq[int] {.compileTime.} =
    for f in VectorFields:
        result = fields.map_it f.find it
        if -1 notin result:
            return result

    error &"Invalid swizzle fields for vector: '{fields}'. Valid fields include '{VectorFields}'"

macro `.`*(v: Swizzleable; fields: untyped): untyped =
    let inds = to_inds fields.repr
    if inds.len == 1:
        let i = inds[0]
        result = quote:
            `v`[`i`]
    else:
        result = new_nim_node nnkCall
        result.add ident "vec"
        for i in inds:
            result.add quote do:
                `v`[`i`]

macro `.=`*(v: Swizzleable; fields, rhs: untyped): untyped =
    let cnt  = fields.repr.len
    let inds = to_inds fields.repr
    if cnt == 1:
        let i = inds[0]
        result = quote:
            `v`[`i`] = `rhs`
    else:
        result  = new_stmt_list()
        let tmp = gen_sym()
        result.add quote do:
            let `tmp` = `rhs`
        for (i, idx) in enumerate inds:
            result.add quote do:
                `v`[`idx`] = `tmp`[`i`]
