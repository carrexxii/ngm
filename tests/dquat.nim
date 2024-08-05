import std/unittest, ngm

var
    q1 = dquat(quat(1, 2, 3, 4), quat(5, 6, 7, 0))
    q2 = dquat(quat(0.77, 0, 0, 0.77), quat(1, 1, 1, 0))
    q3 = DQuatIdent

echo q1
echo q2
echo q3
