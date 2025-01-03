# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, util, vector, matrix

type
    Point2D* = distinct Vec2
    Point3D* = distinct Vec3

    Rect* = object
        x*, y*: Real
        w*, h*: Real
    # Volume* = object
    #     x*, y*, z*: Real
    #     w*, h*, d*: Real

{.push inline.}

func `[]`*(p: Point2D; i: range[0..1]): Real = cast[Vec2](p)[i]
func `[]`*(p: Point3D; i: range[0..2]): Real = cast[Vec3](p)[i]
func `[]=`*(p: var Point2D; i: range[0..1]; val: Real) = cast[ptr UncheckedArray[Real]](p.addr)[i] = val
func `[]=`*(p: var Point3D; i: range[0..2]; val: Real) = cast[ptr UncheckedArray[Real]](p.addr)[i] = val

# TODO: isolate swizzling from vector
func x*(p: Point2D | Point3D): Real = p[0]
func y*(p: Point2D | Point3D): Real = p[1]
func z*(p: Point3D): Real           = p[2]

func `$`*(p: Point2D): string {.borrow.} #= &"({p.x}, {p.y})"
func `$`*(p: Point3D): string {.borrow.} #= &"({p.x}, {p.y}, {p.z})"

func repr*(p: Point2D): string = &"Point2D (x: {p.x}, y: {p.y})"
func repr*(p: Point3D): string = &"Point3D (x: {p.x}, y: {p.y}, z: {p.z})"

func point*(x, y: Real): Point2D    = Point2D [x, y]
func point*(x, y, z: Real): Point3D = Point3D [x, y, z]

func vec*(p: Point2D): Vec3 = vec p.x, p.y, 1.0
func vec*(p: Point3D): Vec4 = vec p.x, p.y, p.z, 1.0

func norm*(p: Point2D): Real {.borrow.}
func norm*(p: Point3D): Real {.borrow.}
func mag*(p: Point2D): Real {.borrow.}
func mag*(p: Point3D): Real {.borrow.}

func `==`*(p1, p2: Point2D): bool {.borrow.}
func `==`*(p1, p2: Point3D): bool {.borrow.}

func `=~`*(p1, p2: Point2D): bool {.borrow.}
func `=~`*(p1, p2: Point3D): bool {.borrow.}

func `-`*(p: Point2D): Point2D {.borrow.}
func `-`*(p: Point3D): Point3D {.borrow.}

func `+`*(p: Point2D; v: Vec2): Point2D {.borrow.}
func `+`*(p: Point3D; v: Vec3): Point3D {.borrow.}
func `*`*(s: Real; p: Point2D): Point2D {.borrow.}
func `*`*(s: Real; p: Point3D): Point3D {.borrow.}
func `*`*(p: Point2D; s: Real): Point2D {.borrow.}
func `*`*(p: Point3D; s: Real): Point3D {.borrow.}

func `+=`*(p: var Point2D; v: Vec2) {.borrow.}
func `+=`*(p: var Point3D; v: Vec3) {.borrow.}
func `-=`*(p: var Point2D; v: Vec2) {.borrow.}
func `-=`*(p: var Point3D; v: Vec3) {.borrow.}
func `*=`*(p: var Point2D; s: Real) {.borrow.}
func `*=`*(p: var Point3D; s: Real) {.borrow.}

func `-`*(p1, p2: Point2D): Vec2 = vec p1.x - p2.x, p1.y - p2.y
func `-`*(p1, p2: Point3D): Vec3 = vec p1.x - p2.x, p1.y - p2.y, p1.z - p2.z

func `*`*(m: Mat3; p: Point2D): Point2D =
    expand_alias m
    point(m00*p.x + m10*p.y + m20,
          m01*p.x + m11*p.y + m21)
func `*`*(m: Mat4; p: Point3D): Point3D =
    expand_alias m
    point(m00*p.x + m10*p.y + m20*p.z + m30,
          m01*p.x + m11*p.y + m21*p.z + m31,
          m02*p.x + m12*p.y + m22*p.z + m32)

func centre*[T: Point2D | Point3D](p1, p2: T): T = (p1 + vec p2)*0.5

#[ -------------------------------------------------------------------- ]#

func `$`*(r: Rect): string  = &"({r.x}, {r.y}, {r.w}, {r.h})"
func repr*(r: Rect): string = &"Rect (x: {r.x}, y: {r.y}, w: {r.w}, h: {r.h})"

func rect*(x: SomeNumber, y: SomeNumber, w: SomeNumber, h: SomeNumber): Rect =
    Rect(x: Real x, y: Real y, w: Real w, h: Real h)
func rect*(p1, p2: Point2D): Rect  = rect p1.x, p1.y, p2.x - p1.x, p2.y - p1.y
func arr*(r: Rect): array[4, Real] = [r.x, r.y, r.w, r.h]

func `==`*(r1, r2: Rect): bool = (r1.x == r2.x) and (r1.y == r2.y) and (r1.w == r2.w) and (r1.h == r2.h)
func `=~`*(r1, r2: Rect): bool = (r1.x =~ r2.x) and (r1.y =~ r2.y) and (r1.w =~ r2.w) and (r1.h =~ r2.h)

func `+`*(r: Rect; v: Vec2): Rect = rect r.x + v.x, r.y + v.y, r.w, r.h
func `-`*(r: Rect; v: Vec2): Rect = rect r.x - v.x, r.y - v.y, r.w, r.h
func `*`*(r: Rect; s: Real): Rect = rect r.x, r.y, s*r.w, s*r.h
func `/`*(r: Rect; s: Real): Rect = rect r.x, r.y, r.w/s, r.h/s
func `*`*(s: Real; r: Rect): Rect = r*s

func `+=`*(r: var Rect; v: Vec2) = r = r + v
func `-=`*(r: var Rect; v: Vec2) = r = r - v
func `*=`*(r: var Rect; s: Real) = r = r*s
func `/=`*(r: var Rect; s: Real) = r = r/s

func centre*(r: Rect): Point2D = point r.x + r.w/2, r.y + r.h/2

func intersection*(r1, r2: Rect): Rect =
    let x1 = max(r1.x       , r2.x)
    let y1 = max(r1.y       , r2.y)
    let x2 = min(r1.x + r1.w, r2.x + r2.w)
    let y2 = min(r1.y + r1.h, r2.y + r2.h)
    if x1 < x2 and y1 < y2:
        rect x1, y1, x2 - x1, y2 - y1
    else:
        rect 0, 0, 0, 0

func union(r1, r2: Rect): Rect =
    let x1 = min(r1.x       , r2.x)
    let y1 = min(r1.y       , r2.y)
    let x2 = max(r1.x + r1.w, r2.x + r2.w)
    let y2 = max(r1.y + r1.h, r2.y + r2.h)
    rect x1, y1, x2 - x1, y2 - y1

func `∩`*(r1, r2: Rect): Rect = intersection r1, r2
func `∪`*(r1, r2: Rect): Rect = union r1, r2

func intersects*(r1, r2: Rect): bool =
    (r1.x + r1.w > r2.x) and (r1.x < r2.x + r2.w) and
    (r1.y + r1.h > r2.y) and (r1.y < r2.y + r2.h)

func contains*(r: Rect; p: Point2D): bool =
    (p.x >= r.x) and (p.x <= r.x + r.w) and
    (p.y >= r.y) and (p.y <= r.y + r.h)

{.pop.}

when defined NgmMode2D:
    type Point* = Point2D
elif defined NgmMode3D:
    type Point* = Point3D
