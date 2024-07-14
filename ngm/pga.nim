# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import
    std/[macros, strutils, sequtils, algorithm],
    common

type
    Real  = float
    Basis = Real

func name_of_basis(basis: string): string =
    if basis == "Real":
        result = "scalar"
    else:
        result = basis.multi_replace(
            ("e", ""),
            ("1", "x"),
            ("2", "y"),
            ("3", "z"),
            ("0", "w"),
        )

func blade_abbrev(blade: string): string =
    case to_lower_ascii blade
    of "real"        : result = "scalar"
    of "vector"      : result = "vec"
    of "bivector"    : result = "bivec"
    of "trivector"   : result = "trivec"
    of "pseudoscalar": result = "pss"
    of "multivector" : result = "multivec"
    else:
        assert(false, &"Failed to match '{blade}' to an abbreviation")

macro gen_algebra(comps: varargs[tuple[id: string, sq: int]]): untyped =
    var full_basis = nnkConstDef.newTree(
        nnkPostfix.newTree(ident "*", ident "FullBasis"),
        newEmptyNode(),
        newTree nnkBracket,
    )

    var bases   = comps.map_it $it[0]
    let squares = comps.map_it it[1]

    # echo product [bases, bases]
    # echo product [product [bases, bases], product [bases, bases]]
    for x in

    while next_permutation bases:
        echo bases
    # echo perms
    quit 0

    result = newNimNode nnkStmtList
    for basis in comps:
        let name = ident("'" & $basis)
        result.add quote("@@") do:
            type `@@basis`* = distinct Basis
            proc `@@name`*(x: string): @@basis {.compileTime.} = @@basis (parse_float x)
            func `$`*(x: @@basis): string = $(Real x) & (repr @@basis)

            func `+`*(a, b: @@basis): @@basis {.borrow.}
            func `-`*(a, b: @@basis): @@basis {.borrow.}
            proc `+=`*(a: var `@@basis`; b: @@basis) {.borrow.}
            proc `-=`*(a: var `@@basis`; b: @@basis) {.borrow.}

            proc `*=`*(a: var `@@basis`; b: @@basis) {.borrow.}
            func `*`*(a, b: @@basis): @@basis {.borrow.}
            func `/`*(a, b: @@basis): @@basis {.borrow.}
            proc `/=`*(a: var `@@basis`; b: @@basis) {.borrow.}

            func `==`*(a, b: @@basis): bool {.borrow.}
            func `<=`*(a, b: @@basis): bool {.borrow.}
            func `<` *(a, b: @@basis): bool {.borrow.}

        full_basis[2].add (newLit $basis)

    result.add(nnkConstSection.newTree full_basis)
    echo repr result

gen_algebra(("e0", 0), ("e1", 1), ("e2", 1))
# gen_algebra(e0, e1, e2, e01, e20, e12, e012)

# when defined PGA2D:
#     gen_algebra(e0, e1, e2, e3, e01, e20, e12, e012)
# elif defined PGA3D:
#     gen_algebra(e0, e1, e2, e3, e01, e02, e03, e12, e31, e23, e021, e013, e032, e123, e0123)

func build_ctor(name: string; param_list: openArray[string]): NimNode {.compileTime.} =
    var params = @[ident name]
    var ctor   = newNimNode nnkStmtList
    for (i, param) in enumerate param_list:
        let kind  = ident $param
        let field = ident(name_of_basis $param)
        ctor.add quote do:
            result.`field` = `kind` `field`

        params.add newIdentDefs(field, ident $Real, newLit 0)

    let name = ident $(to_lower_ascii $name)
    result = newProc(name.postfix "*",
        proc_type = nnkFuncDef,
        pragmas   = nnkPragma.newTree(ident "inline"),
        params    = params,
        body      = ctor,
    )

macro gen_blades(blades: varargs[untyped]): untyped =
    var blade_list: seq[string] # Need this for operator resolution without `AllBlades` defined yet
    var all_blades = nnkConstDef.newTree(
        nnkPostfix.newTree(ident "*", ident "AllBlades"),
        newEmptyNode(),
        newTree nnkBracket,
    )

    result = newNimNode nnkStmtList
    let multivec_fields = nnkRecList.newTree(
        nnkIdentDefs.newTree(
            nnkPostfix.newTree(ident "*", ident "scalar"),
            ident $Real,
            newLit 0
        )
    )
    for (i, blade) in enumerate blades:
        let blade_bases = FullBasis.filter((basis: string) => basis.len - 2 == i)

        var components = newNimNode nnkRecList
        for basis in blade_bases:
            let name = name_of_basis basis
            components.add nnkIdentDefs.newTree(
                nnkPostfix.newTree(ident "*", ident name),
                ident basis,
                nnkCommand.newTree(ident basis, newLit 0)
            )

            multivec_fields.add nnkIdentDefs.newTree(
                nnkPostfix.newTree(ident "*", ident name),
                ident basis,
                nnkCommand.newTree(ident basis, newLit 0)
            )

        # Type definition
        result.add nnkTypeSection.newTree(
            nnkTypeDef.newTree(
                nnkPostfix.newTree(ident "*", `blade`),
                newEmptyNode(),
                nnkObjectTy.newTree(
                    newEmptyNode(),
                    newEmptyNode(),
                    components
                )
            )
        )

        # Homogeneous operators
        var fields = nnkStmtList.newTree()
        for basis in blade_bases:
            let basis = ident(name_of_basis basis)
            fields.add quote do:
                result.`basis` = a.`basis` + b.`basis`
        result.add newProc(postfix(ident "+", "*"),
            procType = nnkFuncDef,
            params = [`blade`,
                newIdentDefs(ident "a", `blade`),
                newIdentDefs(ident "b", `blade`),
            ],
            body = fields,
        )

        # Converters to blades
        for basis in blade_bases:
            let field = ident(name_of_basis basis)
            let name  = ident(basis & "_to_" & (to_lower_ascii $blade))
            let basis = ident basis
            result.add quote do:
                converter `name`*(a: `basis`): `blade` =
                    result.`field` = a

        # Stringingfy / `$`
        let blade_count = blade_bases.len
        var sb = nnkStmtList.newTree(
            newVarStmt(ident "comps", quote do: new_seq_of_cap[string] `blade_count`)
        )
        for (j, basis) in enumerate blade_bases:
            let field  = ident(name_of_basis basis)
            let append = if j < blade_bases.len - 1: " + " else: ""
            let basis  = ident basis
            sb.add quote do:
                if a.`field` != `basis` 0.0:
                    comps.add $a.`field`
        sb.add quote do:
            result = $`blade` & ": " & (comps.join " + ")

        result.add newProc(postfix(ident "$", "*"),
            procType = nnkFuncDef,
            params = [ident "string",
                newIdentDefs(ident "a", `blade`)
            ],
            body = sb
        )

        result.add build_ctor($blade, FullBasis.filter((basis: string) => basis.len - 2 == i))
        blade_list.add $blade

    # Multivector
    result.add nnkTypeSection.newTree(
        nnkTypeDef.newTree(
            nnkPostFix.newTree(ident "*", ident "Multivector"),
            newEmptyNode(),
            nnkObjectTy.newTree(
                newEmptyNode(),
                newEmptyNode(),
                multivec_fields
            )
        )
    )
    result.add build_ctor("Multivector", @FullBasis & $Real)

    # Special blade-based constructor for converters
    let scalar = ident(blade_abbrev $Real)
    var mv_params  = @[ident "Multivector",
                       newIdentDefs(scalar, ident $Real, newLit 0)]
    var mv_assigns = @[quote do: result.`scalar` = `scalar`]
    for (i, blade) in enumerate blade_list:
        let name  = ident(blade_abbrev blade)
        let blade = ident blade
        mv_params.add newIdentDefs(name, blade, newCall blade)

        for basis in FullBasis.filter((basis: string) => basis.len - 2 == i):
            let basis = ident(name_of_basis basis)
            mv_assigns.add quote do:
                result.`basis` = `name`.`basis`

    let name = ident "multivector"
    result.add newProc(name.postfix "*",
        procType = nnkFuncDef,
        params   = mv_params,
        body     = newStmtList mv_assigns,
    )

    # Converters to multivector
    for (i, blade) in enumerate blades:
        let blade_bases = FullBasis.filter((basis: string) => basis.len - 2 == i)
        let name        = ident((to_lower_ascii $blade) & "_to_multivector")
        var fb = nnkStmtList.newTree()
        for basis in blade_bases:
            let field = ident(name_of_basis basis)
            fb.add quote do:
                result.`field` = a.`field`

        result.add newProc(name.postfix "*",
            procType = nnkConverterDef,
            params = [ident "Multivector",
                newIdentDefs(ident "a", `blade`)
            ],
            body = fb
        )

    # Stringify / `$` for Multivector
    let blade_count = FullBasis.len
    var sb = nnkStmtList.newTree(
        newVarStmt(ident "comps", quote do: new_seq_of_cap[string] `blade_count`)
    )
    for (j, basis) in enumerate FullBasis:
        let field  = ident(name_of_basis basis)
        let append = if j < blade_count - 1: " + " else: ""
        let basis  = ident basis
        sb.add quote do:
            if a.`field` != `basis` 0.0:
                comps.add $a.`field`
    sb.add quote do:
        result = "Multivector: " & (comps.join " + ")

    result.add newProc(postfix(ident "$", "*"),
        procType = nnkFuncDef,
        params = [ident "string",
            newIdentDefs(ident "a", ident "Multivector")
        ],
        body = sb
    )

    var blade: NimNode
    for b in product [@FullBasis, @FullBasis]:
        if b[0] == b[1]:
            continue

        if b[0].len == b[1].len:
            blade = ident blade_list[b[0].len - 2]
        else:
            blade = ident "Multivector"

        let T = ident b[0]; let t = ident(name_of_basis $T)
        let U = ident b[1]; let u = ident(name_of_basis $U)
        let ctor = ident(to_lower_ascii $blade)
        result.add quote("@@") do:
            func `+`*(a: `@@T`; b: `@@U`): `@@blade` =
                `@@ctor`(`@@t` = Real a, `@@u` = Real b)
        # echo repr result
        # quit 0

    # Ops for differing blades
    for b in product [blade_list, blade_list]:
        if b[0] == b[1]:
            continue

        let T = ident b[0]; let t = ident(blade_abbrev b[0])
        let U = ident b[1]; let u = ident(blade_abbrev b[1])
        result.add quote("@@") do:
            func `+`*(a: `@@T`; b: `@@U`): Multivector = multivector(@@t = a, @@u = b)

    for blade in blade_list:
        all_blades[2].add(newLit blade)
    result.add(nnkConstSection.newTree all_blades)
    echo repr result

gen_blades(Vector, Bivector, PseudoScalar)
# when defined PGA2D:
#     gen_blades(Vector, Bivector, PseudoScalar)
# elif defined PGA3D:
#     gen_blades(Vector, Bivector, Trivector, PseudoScalar)
