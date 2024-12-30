import std/typetraits

type BorrowKind* = enum
    bkAdditive
    bkMultiplicative
    bkComparable
    bkPrintable

template borrow_additive*(T: typedesc) =
    func `+`*(a: T): T {.borrow.}
    func `-`*(a: T): T {.borrow.}

    func `+`*(a, b: T): T {.borrow.}
    func `-`*(a, b: T): T {.borrow.}

    func `+=`*(a: var T; b: T) {.borrow.}
    func `-=`*(a: var T; b: T) {.borrow.}

template borrow_multiplicative*(T: typedesc; base = distinct_base T) =
    func `*`*(a: T; b: base): T {.borrow.}
    func `/`*(a: T; b: base): T {.borrow.}
    func `*`*(a: base; b: T): T {.borrow.}
    when base is SomeInteger:
        func `div`*(a: T; b: int): T {.borrow.}
        func `mod`*(a: T; b: int): T {.borrow.}

template borrow_comparable*(T: typedesc) =
    func `<`*(a, b: T): bool  {.borrow.}
    func `<=`*(a, b: T): bool {.borrow.}
    func `==`*(a, b: T): bool {.borrow.}

template borrow_printable*(T: typedesc) =
    func repr*(a: T): string {.borrow.}
    func `$`*(a: T): string  {.borrow.}

template borrow*(T: typedesc; kinds: varargs[BorrowKind]) =
    when bkAdditive       in kinds: borrow_additive T
    when bkMultiplicative in kinds: borrow_multiplicative T
    when bkComparable     in kinds: borrow_comparable T
    when bkPrintable      in kinds: borrow_printable T

template borrow_unit*(T: typedesc) = T.borrow bkAdditive, bkMultiplicative, bkComparable, bkPrintable
