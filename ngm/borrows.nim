# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

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

template borrow_multiplicative*(T: typedesc) =
    func `*`*(a: T; b: distinct_base T): T {.borrow.}
    func `/`*(a: T; b: distinct_base T): T {.borrow.}
    func `*`*(a: distinct_base T; b: T): T {.borrow.}

    func `*=`*(a: var T; b: distinct_base T) {.borrow.}
    func `/=`*(a: var T; b: distinct_base T) {.borrow.}

    when (distinct_base T) is SomeInteger:
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
