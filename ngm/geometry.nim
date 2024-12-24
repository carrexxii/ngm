# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import common, util, vector

type
    Point2D* = object
        x*, y*: Real
    Point3D* = object
        x*, y*, z*: Real

{.push inline.}

func `$`*(p: Point2D): string = &"({p.x}, {p.y})"
func `$`*(p: Point3D): string = &"({p.x}, {p.y}, {p.z})"

func repr*(p: Point2D): string = &"Point2D (x: {p.x}, y: {p.y})"
func repr*(p: Point3D): string = &"Point3D (x: {p.x}, y: {p.y}, z: {p.z})"

func point*(x, y   : SomeNumber): Point2D = Point2D(x: Real x, y: Real y)
func point*(x, y, z: SomeNumber): Point3D = Point3D(x: Real x, y: Real y, z: Real z)

func point*(v: Vec2): Point2D = Point2D(x: v.x, y: v.y)
func point*(v: Vec3): Point3D = Point3D(x: v.x, y: v.y, z: v.z)

func vec*(p: Point2D): Vec2 = vec(p.x, p.y)
func vec*(p: Point3D): Vec3 = vec(p.x, p.y, p.z)

func arr*(p: Point2D): array[2, Real] = [p.x, p.y]
func arr*(p: Point3D): array[3, Real] = [p.x, p.y, p.z]

func `==`*(p1, p2: Point2D): bool = (p1.x == p2.x) and (p1.y == p2.y)
func `==`*(p1, p2: Point3D): bool = (p1.x == p2.x) and (p1.y == p2.y) and (p1.z == p2.z)

func `~=`*(p1, p2: Point2D): bool = (p1.x ~= p2.x) and (p1.y ~= p2.y)
func `~=`*(p1, p2: Point3D): bool = (p1.x ~= p2.x) and (p1.y ~= p2.y) and (p1.z ~= p2.z)

func `-`*(p: Point2D): Point2D = point(-p.x, -p.y)
func `-`*(p: Point3D): Point3D = point(-p.x, -p.y, -p.z)

func `+`*(p: Point2D; v: Vec2): Point2D = point(p.x + v.x, p.y + v.y)
func `+`*(p: Point3D; v: Vec3): Point3D = point(p.x + v.x, p.y + v.y, p.z + v.z)
func `+=`*(p: var Point2D; v: Vec2) = p = p + v
func `+=`*(p: var Point3D; v: Vec3) = p = p + v

func `-`*(p1, p2: Point2D): Vec2 = vec(p1.x - p2.x, p1.y - p2.y)
func `-`*(p1, p2: Point3D): Vec3 = vec(p1.x - p2.x, p1.y - p2.y, p1.z - p2.z)
func `-=`*(p: var Point2D; v: Vec2) = p = p + -v
func `-=`*(p: var Point3D; v: Vec3) = p = p + -v

func `*`*(s: Real; p: Point2D): Point2D = point(s*p.x, s*p.y)
func `*`*(s: Real; p: Point3D): Point3D = point(s*p.x, s*p.y, s*p.z)
func `*`*(p: Point2D; s: Real): Point2D = s*p
func `*`*(p: Point3D; s: Real): Point3D = s*p
func `*=`*(p: var Point2D; s: Real) = p = s*p
func `*=`*(p: var Point3D; s: Real) = p = s*p

func centre*[T: Point2D | Point3D](p1, p2: T): T = (p1 + vec(p2))*0.5

{.pop.}

when defined NgmMode2D:
    type Point* = Point2D
elif defined NgmMode3D:
    type Point* = Point3D
