block Pga3D:
    var
        p = vec(1, 1, 1, 1)
        q = vec(2, 2, 2, 1)
        l = bivec(1, 2, 3, 3, 2, 1)
        m = bivec(1, 1, 1, 2, 2, 2)
        g = trivec(2, 4, 6, 1)
        h = trivec(-1, -2, -3, 2)

    test "Stringify":
        check:
            $p == "[1.0, 1.0, 1.0, 1.0]"
            $q == "[2.0, 2.0, 2.0, 1.0]"
            $l == "(1.0, 2.0, 3.0, 3.0, 2.0, 1.0)"
            $m == "(1.0, 1.0, 1.0, 2.0, 2.0, 2.0)"
            $g == "(2.0, 4.0, 6.0, 1.0)"
            $h == "(-1.0, -2.0, -3.0, 2.0)"

    test "Attributes":
        check:
            p.bulk == vec(1, 1, 1, 0)
            q.bulk == vec(2, 2, 2, 0)
            l.bulk == bivec(default Vec3, vec(3, 2, 1))
            m.bulk == bivec(default Vec3, vec(2, 2, 2))
            g.bulk == trivec(0, 0, 0, 1)
            h.bulk == trivec(0, 0, 0, 2)

        check:
            p.weight == vec(0, 0, 0, 1)
            q.weight == vec(0, 0, 0, 1)
            l.weight == bivec(vec(1, 2, 3), default Vec3)
            m.weight == bivec(vec(1, 1, 1), default Vec3)
            g.weight == trivec(2, 4, 6, 0)
            h.weight == trivec(-1, -2, -3, 0)

        check:
            ★p == trivec(1, 1, 1, 0)
            ★q == trivec(2, 2, 2, 0)
            ★l == bivec(-vec(3, 2, 1), default Vec3)
            ★m == bivec(-vec(2, 2, 2), default Vec3)
            ★g == vec(0, 0, 0, -g.w)
            ★h == vec(0, 0, 0, -h.w)

        check:
            ★~p == trivec(0, 0, 0, 1)
            ★~q == trivec(0, 0, 0, 1)
            ★~l == bivec(default Vec3, -vec(1, 2, 3))
            ★~m == bivec(default Vec3, -vec(1, 1, 1))
            ★~g == vec(-2, -4, -6, 0)
            ★~h == vec(1, 2, 3, 0)

        check:
            p.bulk_norm == norm p.xyz
            q.bulk_norm == norm q.xyz
            l.bulk_norm == norm l.m
            m.bulk_norm == norm m.m
            g.bulk_norm == abs g.w
            h.bulk_norm == abs h.w

        check:
            p.weight_norm == Antiscalar3D 1
            q.weight_norm == Antiscalar3D abs q.w
            l.weight_norm == norm l.v
            m.weight_norm == norm m.v
            g.weight_norm == norm [g.x, g.y, g.z]
            h.weight_norm == norm [h.x, h.y, h.z]

        check:
            p.attitude == 1
            q.attitude == q.w
            l.attitude == vec(l.v.x, l.v.y, l.v.z, 0)
            m.attitude == vec(m.v.x, m.v.y, m.v.z, 0)
            g.attitude == bivec(default Vec3, vec(g.x, g.y, g.z))
            h.attitude == bivec(default Vec3, vec(h.x, h.y, h.z))

        check:
            p.right_complement == trivec(p.x, p.y, p.z, 1)
            q.right_complement == trivec(q.x, q.y, q.z, q.w)
            l.right_complement == bivec(-l.m, -l.v)
            m.right_complement == bivec(-m.m, -m.v)
            g.right_complement == vec(-g.x, -g.y, -g.z, -g.w)
            h.right_complement == vec(-h.x, -h.y, -h.z, -h.w)
