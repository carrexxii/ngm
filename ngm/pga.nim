import
    std/[macros, strutils],
    common

type
    Real  = float
    Basis = Real

func name_of_basis(basis: string): string =
    result = basis.multi_replace(
        ("e", ""),
        ("1", "x"),
        ("2", "y"),
        ("3", "z"),
        ("0", "w"),
    )

macro gen_algebra(comps: varargs[untyped]): untyped =
    var vecs = nnkConstDef.newTree(
        ident "full_basis",
        newEmptyNode(),
        newTree nnkBracket,
    )

    result = newNimNode nnkStmtList
    for basis in comps:
        let name = ident("'" & $basis)
        result.add quote("@@") do:
            type `@@basis`* = distinct Basis
            template `@@name`*(x: string): @@basis = @@basis (parse_float x)
            template `$`*(x: @@basis): string = $(Real x) & (repr @@basis)

            func `+`*(a, b: @@basis): @@basis {.borrow.}
            func `-`*(a, b: @@basis): @@basis {.borrow.}
            func `*`*(a, b: @@basis): @@basis {.borrow.}
            func `/`*(a, b: @@basis): @@basis {.borrow.}
            proc `+=`*(a: var `@@basis`; b: @@basis) {.borrow.}
            proc `-=`*(a: var `@@basis`; b: @@basis) {.borrow.}
            proc `*=`*(a: var `@@basis`; b: @@basis) {.borrow.}
            proc `/=`*(a: var `@@basis`; b: @@basis) {.borrow.}

            func `==`*(a, b: @@basis): bool {.borrow.}
            func `<=`*(a, b: @@basis): bool {.borrow.}
            func `<` *(a, b: @@basis): bool {.borrow.}

        vecs[2].add (newLit $basis)

    result.add (nnkConstSection.newTree vecs)
    # echo repr result[0]

when defined PGA2D:
    gen_algebra(e0, e1, e2, e3, e01, e20, e12, e012)

macro gen_blades(blades: varargs[untyped]): untyped =
    result = newNimNode nnkStmtList
    for (i, blade) in enumerate blades:
        var components = newNimNode nnkRecList
        for basis in full_basis:
            if basis.len - 2 != i:
                continue

            let name = name_of_basis basis
            components.add nnkIdentDefs.newTree(
                nnkPostfix.newTree(ident "*", ident name),
                ident basis,
                newEmptyNode()
            )

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

    echo repr result

when defined PGA2D:
    gen_blades(Vector, Bivector, PseudoScalar)

elif defined PGA3D:
    algebra(e0, e1, e2, e3, e01, e02, e03, e12, e31, e23, e021, e013, e032, e123, e0123)
    assert false
