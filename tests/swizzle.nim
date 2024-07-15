import std/[unittest, strformat], ngm

var
    v1 = vec(1, 2, 3)
    v2 = vec(4, 5, 6)
    v3 = vec(-1, -3, -5)

echo "===== Swizzle Tests ====="
echo &"    v1 = {v1}; v2 = {v2}; v3 = {v3}"

check:
    v1.x == 1
    v2.y == 5
    v3.z == -5

check:
    v1.zx  == vec(3, 1)
    v2.xxy == vec(4, 4, 5)
    v1.xzy == vec(1, 3, 2)
    v3.zxz == vec(-5, -1, -5)

check:
    (v1.x + v2.x) == 5
    (v3.z + v1.y) == -3
    (v2.z + v3.x) == 5

v1 = [1, 8, 9]
v2 = [5, 6, 7]
v3 = [3, 2, 1]
echo "    ..."
echo &"    v1 = {v1};  v2 = {v2}; v3 = {v3}"

check:
    v1.xy  == vec(1, 8)
    v2.zx  == vec(7, 5)
    v3.zzz == vec(1, 1, 1)
    v1.yyz == vec(8, 8, 9)

check:
    (v1.x + v2.y + v3.z)       == 8
    (v1.xy + v2.yz + v3.zx)    == vec(8, 18)
    (v1.xyz + v2.yzx + v3.zxy) == vec(8, 18, 16)
    (v1.xx + v2.yy + v3.zz)    == vec(8, 8)
