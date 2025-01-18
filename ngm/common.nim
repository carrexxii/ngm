# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import std/[enumerate, with, math]
from std/os        import `/`, `/../`, parent_dir
from std/strformat import `&`
export enumerate, with, sqrt, pow, `&`, `/`, `^`

template ngm_assert*(cond, body) =
    when not defined NgmNoAssert:
        assert cond, body

func `=~`*(a, b: SomeFloat): bool = almost_equal(a, b)
template `!=~`*(a, b: SomeFloat): bool = not (a =~ b)
