# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

## https://paulbourke.net/geometry/pointlineplane/
## https://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html

import common, vector

type
    # ALine2D*[T] = object
    #     pos*: AVec2[T]
    #     dir*: AVec2[T]

    ALineSeg2D*[T] = object
        p1*, p2*: AVec2[T]
    ALineSeg3D*[T] = object
        p1*, p2*: AVec3[T]

    LineSeg2DF32* = ALineSeg2D[float32]
    LineSeg2DF64* = ALineSeg2D[float64]
    LineSeg3DF32* = ALineSeg3D[float32]
    LineSeg3DF64* = ALineSeg3D[float64]

    LineSeg2D* = LineSeg2DF32
    LineSeg3D* = LineSeg3DF32

    ALineSeg* = ALineSeg2D | ALineSeg3D

{.push inline.}

func line_seg*[T](p1, p2: AVec2[T]): ALineSeg2D[T] =
    assert p1 !=~ p2
    result.p1 = p1
    result.p2 = p2
func line_seg*[T](p1, p2: AVec3[T]): ALineSeg3D[T] =
    assert p1 !=~ p2
    result.p1 = p1
    result.p2 = p2

func len2*(l: ALineSeg): auto = dist2 l.p1, l.p2
func len*(l: ALineSeg): auto  = dist l.p1, l.p2

func distance2*[T](l: ALineSeg2D[T]; pt: AVec2[T]): T =
    let d = (l.p2.x - l.p1.x)*(l.p1.y - pt.y) - (l.p1.x - pt.x)*(l.p2.y - l.p1.y)
    d / l.len2
func distance*[T](l: ALineSeg2D[T]; pt: AVec2[T]): T = sqrt distance2(l, pt)
func dist2*[T](l: ALineSeg2D[T]; pt: AVec2[T]): T = distance2 l, pt
func dist*[T](l: ALineSeg2D[T]; pt: AVec2[T]): T  = distance l, pt

func intersection*[T](l1, l2: ALineSeg2D[T]): (bool, AVec2[T]) =
    ## Returns `(has_intersection, point_of_intersection)` or `(false, [NaN, NaN])` for parallel lines
    ## `point_of_intersection` can still be valid as a line intersection even if the segments do not intersect
    let
        (x1, x2, x3, x4) = (l1.p1.x, l1.p2.x, l2.p1.x, l2.p2.x)
        (y1, y2, y3, y4) = (l1.p1.y, l1.p2.y, l2.p1.y, l2.p2.y)
        x13 = x1 - x3
        y34 = y3 - y4
        y13 = y1 - y3
        x34 = x3 - x4
        x12 = x1 - x2
        y12 = y1 - y2

    let d = (x12*y34 - y12*x34)
    if d =~ 0: # parallel
        (false, [NaN, NaN])
    else:
        let t =  (x13*y34 - y13*x34) / d
        let u = -(x12*y13 - y12*x13) / d
        let r = (T 0)..(T 1)
        (t in r and u in r, [x1 + t*(x2 - x1), y1 + t*(y2 - y1)])

{.pop.}
