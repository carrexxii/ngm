# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import std/[sugar, enumerate, with]
from std/os        import `/`, `/../`, parent_dir
from std/strformat import `&`
from std/math      import almost_equal
export sugar, enumerate, with, `&`, `/`

type Real* = float32

template ngm_assert*(cond, body) =
    when not defined NgmNoAssert:
        assert cond, body

func `=~`*(a, b: Real): bool = almost_equal(a, b)
