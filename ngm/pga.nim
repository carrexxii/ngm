import
    std/[macros, strutils, sequtils],
    common
from std/algorithm import product

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

macro gen_algebra(comps: varargs[untyped]): untyped =
    var full_basis = nnkConstDef.newTree(
        nnkPostfix.newTree(ident "*", ident "FullBasis"),
        newEmptyNode(),
        newTree nnkBracket,
    )

    result = newNimNode nnkStmtList
    for basis in comps:
        let name = ident("'" & $basis)
        result.add quote("@@") do:
            type `@@basis`* = distinct Basis
            proc `@@name`*(x: string): @@basis {.compileTime.} = @@basis (parse_float x)
            func `$`*(x: @@basis): string = $(Real x) & (repr @@basis)

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

        full_basis[2].add (newLit $basis)

    result.add(nnkConstSection.newTree full_basis)

gen_algebra(e0, e1, e2, e01, e20, e12, e012)
# when defined PGA2D:
#     gen_algebra(e0, e1, e2, e3, e01, e20, e12, e012)
# elif defined PGA3D:
#     gen_algebra(e0, e1, e2, e3, e01, e02, e03, e12, e31, e23, e021, e013, e032, e123, e0123)

# `morph_basis` is used for multivec
func build_ctor(name: string; param_list: openArray[string]; morph_basis = true): NimNode {.compileTime.} =
    var params = newNimNode nnkFormalParams
    var ctor   = newNimNode nnkStmtList
    params.add(ident name)

    for param in param_list:
        let field = if morph_basis: ident(name_of_basis $param)
                    else          : ident(blade_abbrev  $param)
        ctor.add new_assignment(
            newDotExpr(ident "result", field),
            field
        )

        let kind = ident $param
        params.add nnkIdentDefs.newTree(
            field,
            kind,
            if morph_basis or $param == $Real:
                newDotExpr(newLit 0, kind)
            else:
                nnkCall.newTree(ident $param),
        )

    result = nnkStmtList.newTree(
        nnkFuncDef.newTree(
            nnkPostfix.newTree(ident "*", ident $(to_lower_ascii $name)),
            newEmptyNode(),
            newEmptyNode(),
            params,
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree ctor
        )
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
    # result.add build_ctor("Multivector", $Real & blade_list, morph_basis = false)
    result.add build_ctor("Multivector", $Real & @FullBasis)
    # result.add build_ctor("Multivector", [$Real, "Multivector"], morph_basis = false)

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

        # echo &"{b} -> {sum_blade}"
        let T = ident b[0]; let t = ident(name_of_basis $T)
        let U = ident b[1]; let u = ident(name_of_basis $U)
        let ctor = ident(to_lower_ascii $blade)
        result.add quote("@@") do:
            func `+`*(a: `@@T`; b: `@@U`): `@@blade` =
                `@@ctor`(`@@t` = a, `@@u` = b)

    for blade in blade_list:
        all_blades[2].add(newLit blade)
    result.add(nnkConstSection.newTree all_blades)
    echo repr result

gen_blades(Vector, Bivector, PseudoScalar)
# when defined PGA2D:
#     gen_blades(Vector, Bivector, PseudoScalar)
# elif defined PGA3D:
#     gen_blades(Vector, Bivector, Trivector, PseudoScalar)
