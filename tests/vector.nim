import std/unittest, ngm

var
    v = Vec3Zero
    u = vec(1, 2, 3)
    w = vec(3, 5, 7)
    s = vec(3, 4)
    t = vec(7, 7)

check:
    v == vec(0, 0, 0)
    u == vec(1, 2, 3)
    w == vec(3, 5, 7)

check:
    (v + w) == vec(3, 5, 7)
    (w + u) == vec(4, 7, 10)
    (u + v) == vec(1, 2, 3)

check:
    (v - w) == vec(-3, -5, -7)
    (w - u) == vec(2, 3, 4)
    (u - v) == vec(1, 2, 3)

check:
    (v.xy <-> s) ~= 5
    (v <=> u) ~= 14
    (v <-> u) ~= 3.7416573867739413
    (v <=> w) ~= 83
    (v <-> w) ~= 9.1104335791443

check:
    (normalized v) == vec(0, 0, 0)
    (normalized u) == vec(0.2672612369060516, 0.5345224738121033, 0.8017836809158325)
    (normalized w) == vec(0.3292927742004395, 0.5488213300704956, 0.768349826335907)

