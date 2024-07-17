import std/unittest, ngm

var
    A = Mat2x2Ident
    B = Mat3x3Ident
    C = Mat4x4Ident

echo A
echo B
echo C

echo A[0]
echo B[1]
echo C[2]

echo A[1].xy
echo B[2].zxy
echo C[3].yzx

