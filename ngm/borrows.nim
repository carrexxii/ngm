template borrow_numeric*(T, base: typedesc) =
    func `-`*(a: T): T {.borrow.}

    func `+`*(a, b: T): T {.borrow.}
    func `-`*(a, b: T): T {.borrow.}
    proc `+=`*(a: var T; b: T) {.borrow.}
    proc `-=`*(a: var T; b: T) {.borrow.}

    func `*`*(a: T; b: base): T {.borrow.}
    func `*`*(b: base; a: T): T {.borrow.}
    proc `*=`*(a: var T; b: base) {.borrow.}
    when base is SomeFloat:
        func `/`*(a: T; b: base): T {.borrow.}
        func `/`*(b: base; a: T): T {.borrow.}
        proc `/=`*(a: var T; b: base) {.borrow.}
    else:
        func `div`*(a: T; b: base): T {.borrow.}
        func `div`*(b: base; a: T): T {.borrow.}
        func `mod`*(a: T; b: base): T {.borrow.}
        func `mod`*(b: base; a: T): T {.borrow.}

    func `<`* (a, b: T): bool {.borrow.}
    func `<=`*(a, b: T): bool {.borrow.}
    func `==`*(a, b: T): bool {.borrow.}

