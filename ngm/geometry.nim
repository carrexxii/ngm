# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, util, vector, matrix

type
    Circle* = object
        pos*: Vec2
        r*  : float32
    Sphere* = object
        pos*: Vec3
        r*  : float32

    Triangle* = object
        a*, b*, c*: Vec2

    Rect* = object
        x*, y*: float32
        w*, h*: float32
    Cuboid* = object
        x*, y*, z*: float32
        w*, h*, d*: float32

converter rect_to_array*(r: Rect): array[4, float32] = [r.x, r.y, r.w, r.h]

{.push inline.}

func `$`*(r: Rect): string  = &"({r.x}, {r.y}, {r.w}, {r.h})"
func repr*(r: Rect): string = &"Rect (x: {r.x}, y: {r.y}, w: {r.w}, h: {r.h})"

func rect*(x: SomeNumber, y: SomeNumber, w: SomeNumber, h: SomeNumber): Rect =
    Rect(x: float32 x, y: float32 y, w: float32 w, h: float32 h)
func rect*(p1, p2: Vec2): Rect = rect p1.x, p1.y, p2.x - p1.x, p2.y - p1.y

func `==`*(r1, r2: Rect): bool = (r1.x == r2.x) and (r1.y == r2.y) and (r1.w == r2.w) and (r1.h == r2.h)
func `=~`*(r1, r2: Rect): bool = (r1.x =~ r2.x) and (r1.y =~ r2.y) and (r1.w =~ r2.w) and (r1.h =~ r2.h)

func `+`*(r: Rect; v: Vec2): Rect = rect r.x + v.x, r.y + v.y, r.w, r.h
func `-`*(r: Rect; v: Vec2): Rect = rect r.x - v.x, r.y - v.y, r.w, r.h
func `*`*(r: Rect; s: float32): Rect = rect r.x, r.y, s*r.w, s*r.h
func `/`*(r: Rect; s: float32): Rect = rect r.x, r.y, r.w/s, r.h/s
func `*`*(s: float32; r: Rect): Rect = r*s

func `+=`*(r: var Rect; v: Vec2) = r = r + v
func `-=`*(r: var Rect; v: Vec2) = r = r - v
func `*=`*(r: var Rect; s: float32) = r = r*s
func `/=`*(r: var Rect; s: float32) = r = r/s

func centre*(r: Rect): Vec2 = [r.x + r.w/2, r.y + r.h/2]

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

func contains*(r: Rect; p: Vec2): bool =
    (p.x >= r.x) and (p.x <= r.x + r.w) and
    (p.y >= r.y) and (p.y <= r.y + r.h)

#[ -------------------------------------------------------------------- ]#

func area2*(p, q, r: Vec2): float32 =
    (q.x - p.x)*(r.y - p.y) -
    (q.y - p.y)*(r.x - p.x)
func area*(p, q, r: Vec2): float32 = 0.5*area2(p, q, r)

{.pop.}

when defined NgmMode2D:
    type Point* = Point2D
elif defined NgmMode3D:
    type Point* = Point3D
