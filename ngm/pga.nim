import
    std/[macros, strutils],
    common
from std/algorithm import product

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

func blade_abbrev(blade: string): string =
    case to_lower_ascii blade
    of "vector"      : result = "vec"
    of "bivector"    : result = "bivec"
    of "trivector"   : result = "trivec"
    of "pseudoscalar": result = "pss"
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

        full_basis[2].add (newLit $basis)

    result.add (nnkConstSection.newTree full_basis)
    # echo repr result[0]

gen_algebra(e0, e1, e2, e3, e01, e20, e12, e012)
# when defined PGA2D:
#     gen_algebra(e0, e1, e2, e3, e01, e20, e12, e012)
# elif defined PGA3D:
#     gen_algebra(e0, e1, e2, e3, e01, e02, e03, e12, e31, e23, e021, e013, e032, e123, e0123)

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
            quote do: Real,
            newEmptyNode()
        )
    )
    for (i, blade) in enumerate blades:
        var components = newNimNode nnkRecList
        for basis in FullBasis:
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

        multivec_fields.add nnkIdentDefs.newTree(
            nnkPostfix.newTree(ident "*", ident (blade_abbrev $blade)),
            `blade`,
            newEmptyNode()
        )

        blade_list.add $blade

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

    var sum_blade : NimNode
    # var prod_blade: string
    for b in product [@FullBasis, @FullBasis]:
        if b[0] == b[1]:
            continue

        if b[0].len == b[1].len:
            sum_blade = ident blade_list[b[0].len - 2]
        else:
            sum_blade = ident "Multivector"

        echo &"{b} -> {sum_blade}"
        let T = ident b[0]
        let U = ident b[1]
        let ctor = ident (to_lower_ascii $sum_blade)
        result.add quote("@@") do:
            template `+`*(a: `@@T`; b: `@@U`): `@@sum_blade` = `@@ctor`(a, b)

    for blade in blade_list:
        all_blades[2].add (newLit blade)
    result.add (nnkConstSection.newTree all_blades)
    echo repr result

gen_blades(Vector, Bivector, PseudoScalar)
# when defined PGA2D:
#     gen_blades(Vector, Bivector, PseudoScalar)
# elif defined PGA3D:
#     gen_blades(Vector, Bivector, Trivector, PseudoScalar)
