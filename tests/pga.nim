import std/[strutils, unittest, sugar], ngm
from std/strformat import `&`

var
    s = Scalar 3
    v = vec(1, 2, 3)
    b = bivec(3, 2, 1, 5, 4, 3)
    t = trivec(3, 4, 5, 6)
    a = AntiScalar 7

dump s
dump v
dump b
dump t
dump a

check:
    s.grade == 0
    v.grade == 1
    b.grade == 2
    t.grade == 3
    a.grade == 4

check:
    s.antigrade == 4
    v.antigrade == 3
    b.antigrade == 2
    t.antigrade == 1
    a.antigrade == 0

check:
    s.bulk == s
    v.bulk == vec3(v.x, v.y, v.z)
    b.bulk == vec3(b.yz, b.zx, b.xy)
    t.bulk == t.zyx
    a.bulk == 0

check:
    s.weight == 0
    v.weight == v.w
    b.weight == vec3(b.wx, b.wy, b.wz)
    t.weight == vec3(t.wyz, t.wzx, t.wxy)
    a.weight == a
