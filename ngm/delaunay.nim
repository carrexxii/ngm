# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

## https://cp-algorithms.com/geometry/delaunay.html
## .. Note::
##   The implementation of [is_in_circum_circle] is broken

import common, util, vector, geometry
from std/algorithm import sorted
from std/sequtils  import to_seq

type QuadEdge = object
    origin: Vec2
    rot   : ptr QuadEdge
    onext : ptr QuadEdge
    used  : bool

func cross(p, q: Vec2): float32 =
    p.x*q.y - p.y*q.x

func cross(p, q, r: Vec2): float32 =
    cross q - p, r - p

func rev(e: ptr QuadEdge): ptr QuadEdge   = e.rot.rot
func lnext(e: ptr QuadEdge): ptr QuadEdge = e.rot.rev.onext.rot
func oprev(e: ptr QuadEdge): ptr QuadEdge = e.rot.onext.rot
func dest(e: ptr QuadEdge): Vec2          = e.rev.origin

proc create_edge(p, q: Vec2): ptr QuadEdge =
    var e1 = cast[ptr QuadEdge](alloc0 sizeof QuadEdge)
    var e2 = cast[ptr QuadEdge](alloc0 sizeof QuadEdge)
    var e3 = cast[ptr QuadEdge](alloc0 sizeof QuadEdge)
    var e4 = cast[ptr QuadEdge](alloc0 sizeof QuadEdge)

    e1.origin = p
    e2.origin = q
    e3.origin = vec(high float32, high float32)
    e4.origin = vec(high float32, high float32)

    e1.rot = e3
    e2.rot = e4
    e3.rot = e2
    e4.rot = e1

    e1.onext = e1
    e2.onext = e2
    e3.onext = e4
    e4.onext = e3

    return e1

proc splice(e1, e2: ptr QuadEdge) =
    swap e1.onext.rot.onext, e2.onext.rot.onext
    swap e1.onext, e2.onext

proc destroy(e: ptr QuadEdge) =
    splice e, e.oprev
    splice e.rev, e.rev.oprev
    dealloc e.rev.rot
    dealloc e.rev
    dealloc e.rot
    dealloc e

proc connect(e1, e2: ptr QuadEdge): ptr QuadEdge =
    result = create_edge(e1.dest, e2.origin)
    splice result, e1.lnext
    splice result.rev, e2

func is_left_of(p: Vec2; e: ptr QuadEdge): bool =
    p.cross(e.origin, e.dest) > 0

func is_right_of(p: Vec2; e: ptr QuadEdge): bool =
    p.cross(e.origin, e.dest) < 0

func is_in_circum_circle(q, a, b, c: Vec2): bool =
    assert area2(a, b, c) > 0
    let
        ax = a.x - q.x
        ay = a.y - q.y
        bx = b.x - q.x
        by = b.y - q.y
        cx = c.x - q.x
        cy = c.y - q.y
    ((ax*ax + ay*ay)*(bx*cy - cx*by) -
     (bx*bx + by*by)*(ax*cy - cx*ay) +
     (cx*cx + cy*cy)*(ax*by - bx*ay)) < -0.1

proc triangulate(pts: openArray[Vec2]; l, r: int): tuple[e1, e2: ptr QuadEdge] =
    if r - l + 1 == 2:
        let res = create_edge(pts[l], pts[r])
        return (res, res.rev)
    elif r - l + 1 == 3:
        var a = create_edge(pts[l    ], pts[l + 1])
        var b = create_edge(pts[l + 1], pts[r    ])
        splice a.rev, b

        let sign = sign pts[l].cross(pts[l + 1], pts[r])
        if sign == 0:
            return (a, b.rev)

        var c = connect(b, a)
        if sign == 1:
            return (a, b.rev)
        else:
            return (c.rev, c)

    let mid = (l + r) div 2
    var (ldo, ldi) = pts.triangulate(l, mid)
    var (rdi, rdo) = pts.triangulate(mid + 1, r)
    while true:
        if rdi.origin.is_left_of ldi:
            ldi = ldi.lnext
        elif ldi.origin.is_right_of rdi:
            rdi = rdi.rev.onext
        else:
            break

    var basel = connect(rdi.rev, ldi)
    template is_valid(e: ptr QuadEdge): bool =
        e.dest.is_right_of basel
    if ldi.origin == ldo.origin: ldo = basel.rev
    if rdi.origin == rdo.origin: rdo = basel
    while true:
        var lcand = basel.rev.onext
        if lcand.is_valid:
            while lcand.onext.dest.is_in_circum_circle(basel.dest, basel.origin, lcand.dest):
                let tmp = lcand.onext
                destroy lcand
                lcand = tmp

        var rcand = basel.oprev
        if rcand.is_valid:
            while rcand.oprev.dest.is_in_circum_circle(basel.dest, basel.origin, rcand.dest):
                let tmp = rcand.oprev
                destroy rcand
                rcand = tmp

        if (not lcand.is_valid) and (not rcand.is_valid):
            break
        elif (not lcand.is_valid) or rcand.is_valid and
             rcand.dest.is_in_circum_circle(lcand.dest, lcand.origin, rcand.origin):
            basel = connect(rcand, basel.rev)
        else:
            basel = connect(basel.rev, lcand.rev)

    return (ldo, rdo)

proc delaunay*(pts: openArray[Vec2]; is_sorted = false): seq[Vec2] =
    var pts =
        if not is_sorted:
            pts.sorted (proc(a, b: Vec2): int =
                result = int sign(a.x - b.x)
                if result == 0:
                    result = int sign(a.y - b.y)
            )
        else:
            to_seq pts
    let res = pts.triangulate(0, pts.len - 1)
    var e   = res.e1
    var edges = @[e]
    while e.onext.dest.cross(e.dest, e.origin) < 0:
        e = e.onext

    var curr = e
    while true:
        curr.used = true
        pts.add curr.origin
        edges.add curr.rev
        curr = curr.lnext
        if curr == e:
            break

    for i in 0..<edges.len:
        e = edges[i]
        if not e.used:
           curr = e
           while true:
               curr.used = true
               result.add curr.origin
               edges.add curr.rev
               curr = curr.lnext
               if curr == e:
                   break
