# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

if (defined Ngm2D) and (defined Ngm3D):
    assert false, "Both `Ngm2D` and `Ngm3D` should not be simultaneously defined"

import ngm/[util, vector, matrix, quat, dquat, geometry, interpolation, camera, colours]
export      util, vector, matrix, quat, dquat, geometry, interpolation, camera, colours

import ngm/common
export common.`=~`

import std/math
export sqrt, pow, trunc, round, ceil, floor, `^`
