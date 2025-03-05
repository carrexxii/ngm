if (defined Ngm2D) and (defined Ngm3D):
    assert false, "Both `Ngm2D` and `Ngm3D` should not be simultaneously defined"

import ngm/[util, vector, matrix, quat, dquat, geometry, interpolation, camera, colours]
export      util, vector, matrix, quat, dquat, geometry, interpolation, camera, colours

import ngm/common
export common.`=~`

import std/math
export sqrt, pow, trunc, round, ceil, floor, `^`
