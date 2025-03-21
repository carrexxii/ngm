test "Basics":
    var
        v = default Vec3
        u = vec(1, 2, 3)
        w = vec(3, 5, 7)
        s = vec(3, 4)
        t = vec(7, 7)

    check:
        v =~ vec(0, 0, 0)
        u =~ vec(1, 2, 3)
        w =~ vec(3, 5, 7)

    check:
        (v + w) =~ vec(3, 5, 7)
        (w + u) =~ vec(4, 7, 10)
        (u + v) =~ vec(1, 2, 3)

    check:
        (v - w) =~ vec(-3, -5, -7)
        (w - u) =~ vec(2, 3, 4)
        (u - v) =~ vec(1, 2, 3)

    check:
        (v.xy.dist s) =~ 5
        (v.dist2 u)   =~ 14
        (v.dist  u)   =~ 3.7416573867739413
        (v.dist2 w)   =~ 83
        (v.dist  w)   =~ 9.1104335791443

    check:
        (normalized v) =~ vec(0, 0, 0)
        (normalized u) =~ vec(0.2672612369060516, 0.5345224738121033, 0.8017836809158325)
        (normalized w) =~ vec(0.3292927742004395, 0.5488213300704956, 0.768349826335907)

test "Swizzling":
    var
        v1 = vec(1, 2, 3)
        v2 = vec(4, 5, 6)
        v3 = vec(-1, -3, -5)

    check:
        v1.x =~ 1
        v2.y =~ 5
        v3.z =~ -5

    check:
        v1.zx  =~ vec(3, 1)
        v2.xxy =~ vec(4, 4, 5)
        v1.xzy =~ vec(1, 3, 2)
        v3.zxz =~ vec(-5, -1, -5)

    check:
        (v1.x + v2.x) =~ 5
        (v3.z + v1.y) =~ -3
        (v2.z + v3.x) =~ 5

    v1 = [1, 8, 9]
    v2 = [5, 6, 7]
    v3 = [3, 2, 1]
    check:
        v1.xy  =~ vec(1, 8)
        v2.zx  =~ vec(7, 5)
        v3.zzz =~ vec(1, 1, 1)
        v1.yyz =~ vec(8, 8, 9)

    check:
        (v1.x + v2.y + v3.z)       =~ 8
        (v1.xy + v2.yz + v3.zx)    =~ vec(8, 18)
        (v1.xyz + v2.yzx + v3.zxy) =~ vec(8, 18, 16)
        (v1.xx + v2.yy + v3.zz)    =~ vec(8, 8)

    v1.xyz = v1.zyx
    v2.xy  = v2.yx
    v3.yz  = v3.zy
    check:
        v1 =~ vec(9, 8, 1)
        v2 =~ vec(6, 5, 7)
        v3 =~ vec(3, 1, 2)

    v1.xyz = v1.zzz
    v2.yzx = v2.xyx
    v3.zxy = v3.xzy
    check:
        v1 =~ vec(1, 1, 1)
        v2 =~ vec(6, 6, 5)
        v3 =~ vec(2, 1, 3)

    v1.x -= 1
    v2.y -= 1
    v3.z -= 1
    check:
        v1 =~ vec(0, 1, 1)
        v2 =~ vec(6, 5, 5)
        v3 =~ vec(2, 1, 2)
