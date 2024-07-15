import std/[unittest, strformat], ngm

var
    v = Vec3Zero
    u = vec(1, 2, 3)
    w = vec(3, 5, 7)

echo "===== Vector Tests ====="
echo &"    v = {v}; u = {u}; w = {w}"

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

