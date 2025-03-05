# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import common, util, vector, matrix

type
    ATri*[T] = object
        a*, b*, c*: AVec2[T]

    Tri32* = ATri[float32]
    Tri64* = ATri[float64]
    Tri*   = Tri32

#[ -------------------------------------------------------------------- ]#

{.push inline.}

func tri*[T](a, b, c: AVec2[T]): ATri[T] =
    ATri[T](a: a, b: b, c: c)

func area2*[T](tri: ATri[T]): T =
    (tri.b.x - tri.a.x)*(tri.c.y - tri.a.y) -
    (tri.b.y - tri.a.y)*(tri.c.x - tri.a.x)
func area*[T](tri: ATri[T]): T      = 0.5*area2 tri
func area*[T](a, b, c: AVec2[T]): T = 0.5*area2 tri(a, b, c)

{.pop.}
