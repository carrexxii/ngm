# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

## https://paulbourke.net/geometry/polygonmesh/

import common, vector

# IDK if these types would ever be useful
type
    APolygon2D*[N, T] = array[N, AVec2[T]]
    APolygon3D*[N, T] = array[N, AVec3[T]]

    Polygon2DF32*[N] = APolygon2D[N, float32]
    Polygon2DF64*[N] = APolygon2D[N, float64]
    Polygon3DF32*[N] = APolygon3D[N, float32]
    Polygon3DF64*[N] = APolygon3D[N, float64]

    Polygon2D* = Polygon2DF32
    Polygon3D* = Polygon3DF32

    APolygon*[N, T] = APolygon2D[N, T] | APolygon3D[N, T]

{.push inline.}

# TODO: There is a MacMartin method that might be slightly faster
func point_in_poly*[N, T](pt: AVec2[T]; p: openArray[AVec2[T]]): bool =
    var i = int32 0
    var j = int32 p.len - 1
    for i in 0..<p.len:
        if (p[i].y <= pt.y and pt.y < p[j].y) or
           (p[j].y <= pt.y and pt.y < p[i].y):
            if (pt.x < (p[j].x - p[i].x)*(pt.y - p[i].y)/(p[j].y - p[i].y + p[i].x)):
                result = not result
        j = i

{.pop.}
