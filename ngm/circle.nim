# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

## https://paulbourke.net/geometry/circlesphere/

import common, vector, matrix, triangle

type
    ACircle*[T] = object
        pos*: AVec2[T]
        r*  : T

    ASphere*[T] = object
        pos*: AVec3[T]
        r*  : T

    CircleF32* = ACircle[float32]
    CircleF64* = ACircle[float64]
    Circle*    = CircleF32

    SphereF32* = ASphere[float32]
    SphereF64* = ASphere[float64]
    Sphere*    = SphereF32

func circle*[T](p1, p2, p3: AVec2[T]): ACircle[T] =
    assert area(p1, p2, p3) !=~ 0

    let (x1, x2, x3) = (p1.x, p2.x, p3.x)
    let (y1, y2, y3) = (p1.y, p2.y, p3.y)
    let x12 = x1 + x2
    let ma  = (y2 - y1)/(x2 - x1)
    let mb  = (y3 - y2)/(x3 - x2)

    let x = 0.5*(ma*mb*(y1 - y3) + mb*x12 - ma*(x2 + x3)) / (mb - ma)
    let y = -(1/ma)*(x - 0.5*x12) + 0.5*(y1 + y2)
    result.pos = [x, y]
    result.r   = dist(p1, result.pos)

# https://en.wikipedia.org/wiki/Delaunay_triangulation#Algorithms
func in_circumcircle*[T](p, p1, p2, p3: AVec2[T]): bool =
    assert is_ccw(p1, p2, p3)

    let da = [p1.x - p.x, p1.y - p.y]
    let db = [p2.x - p.x, p2.y - p.y]
    let dc = [p3.x - p.x, p3.y - p.y]
    det([[da.x, da.y, da.x^2 + da.y^2],
         [db.x, db.y, db.x^2 + db.y^2],
         [dc.x, dc.y, dc.x^2 + dc.y^2]]) > 0
