var
    p1 = point(1, 2, 3)
    p2 = point(-1, -2, -3)
    p3 = point(0, 0, 0)
    p4 = point(2, 4)
    p5 = point(1, 0)
    p6 = point(-1, -1)

    r1 = rect(10, 10, 80, 30)
    r2 = rect(10, 0, 30, 80)
    r3 = rect(50, 50, 10, 10)
    r4 = rect(100, 100, 10, 10)

test "Stringify":
    check:
        $p1 == "(1.0, 2.0, 3.0)"
        $p2 == "(-1.0, -2.0, -3.0)"
        $p3 == "(0.0, 0.0, 0.0)"
        $p4 == "(2.0, 4.0)"
        $p5 == "(1.0, 0.0)"
        $p6 == "(-1.0, -1.0)"

        $r1 == "(10.0, 10.0, 80.0, 30.0)"
        $r2 == "(10.0, 0.0, 30.0, 80.0)"
        $r3 == "(50.0, 50.0, 10.0, 10.0)"
        $r4 == "(100.0, 100.0, 10.0, 10.0)"

    check:
        p1.repr == "Point3D (x: 1.0, y: 2.0, z: 3.0)"
        p2.repr == "Point3D (x: -1.0, y: -2.0, z: -3.0)"
        p3.repr == "Point3D (x: 0.0, y: 0.0, z: 0.0)"
        p4.repr == "Point2D (x: 2.0, y: 4.0)"
        p5.repr == "Point2D (x: 1.0, y: 0.0)"
        p6.repr == "Point2D (x: -1.0, y: -1.0)"

        r1.repr == "Rect (x: 10.0, y: 10.0, w: 80.0, h: 30.0)"
        r2.repr == "Rect (x: 10.0, y: 0.0, w: 30.0, h: 80.0)"
        r3.repr == "Rect (x: 50.0, y: 50.0, w: 10.0, h: 10.0)"
        r4.repr == "Rect (x: 100.0, y: 100.0, w: 10.0, h: 10.0)"

test "Operators":
    check:
        -p1 =~ point(-1, -2, -3)
        -p2 =~ point(1, 2, 3)
        -p3 =~ point(0, 0, 0)
        -p4 =~ point(-2, -4)
        -p5 =~ point(-1, 0)
        -p6 =~ point(1, 1)

    check:
        (p1 + cast[Vec3](p2)) =~ point(0, 0, 0)
        (p3 + cast[Vec3](p1)) =~ point(1, 2, 3)
        (p5 + cast[Vec2](p6)) =~ point(0, -1)

    check:
        (p2 - p3) =~ vec(-1, -2, -3)
        (p4 - p5) =~ vec(1, 4)
        (p6 - p4) =~ vec(-3, -5)

    check:
        2*p1 =~ point(2, 4, 6)
        2*p2 =~ point(-2, -4, -6)
        2*p3 =~ point(0, 0, 0)
        2*p4 =~ point(4, 8)
        2*p5 =~ point(2, 0)
        2*p6 =~ point(-2, -2)

test "Rects":
    check:
        point(50, 25) == centre r1
        point(25, 40) == centre r2

    check:
        rect(10, 0, 80, 80) == r1 ∪ r2

        rect(10, 10, 30, 30) == r1 ∩ r2

        r1.intersects r2
        not r3.intersects r4

        point(10, 10)  in    r1
        point(25, 70)  in    r2
        point(0, 0)    notin r3
        point(500, 50) notin r4
