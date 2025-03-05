# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import std/[enumerate, with, math]
from std/os        import `/`, `/../`, parent_dir
from std/strformat import `&`
export enumerate, with, sqrt, pow, trunc, round, ceil, floor, `&`, `/`, `^`

template ngm_assert*(cond, body) =
    when not defined NgmNoAssert:
        assert cond, body

func `=~`*(a, b: SomeFloat): bool = almost_equal(a, b)
template `!=~`*(a, b: typed): bool {.dirty.} = not (a =~ b)
