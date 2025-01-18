if (defined Ngm2D) and (defined Ngm3D):
    assert false, "Both `Ngm2D` and `Ngm3D` should not be simultaneously defined"

import ngm/[util, vector, matrix, quat, dquat, pga, geometry, interpolation, camera, delaunay]
export      util, vector, matrix, quat, dquat, pga, geometry, interpolation, camera, delaunay

import ngm/common
export common.`=~`
