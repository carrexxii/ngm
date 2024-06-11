import
    std/[macros, strutils],
    common

type Real = distinct float
func `$`(x: Real): string {.borrow.}

macro algebra(comps: varargs[untyped]): untyped =
    result = newNimNode nnkStmtList
    for basis in comps:
        let name = ident("'" & $basis) #quote("@@") do: `' @@basis`
        result.add quote("@@") do:
            type `@@basis`* = distinct Real
            template `@@name`*(x: string): @@basis = @@basis (parse_float x)
            template `$`*(x: @@basis): string = $(Real x) & (repr @@basis)

    echo repr result

algebra(e0, e1, e2)
