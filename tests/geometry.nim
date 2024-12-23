var
    p1 = point(1, 2, 3)
    p2 = point(-1, -2, -3)
    p3 = point(0, 0, 0)
    p4 = point(2, 4)
    p5 = point(1, 0)
    p6 = point(-1, -1)

test "Stringify":
    check $p1 == "(1.0, 2.0, 3.0)"
    check $p2 == "(-1.0, -2.0, -3.0)"
    check $p3 == "(0.0, 0.0, 0.0)"
    check $p4 == "(2.0, 4.0)"
    check $p5 == "(1.0, 0.0)"
    check $p6 == "(-1.0, -1.0)"

    check p1.repr == "Point3D (x: 1.0, y: 2.0, z: 3.0)"
    check p2.repr == "Point3D (x: -1.0, y: -2.0, z: -3.0)"
    check p3.repr == "Point3D (x: 0.0, y: 0.0, z: 0.0)"
    check p4.repr == "Point2D (x: 2.0, y: 4.0)"
    check p5.repr == "Point2D (x: 1.0, y: 0.0)"
    check p6.repr == "Point2D (x: -1.0, y: -1.0)"

test "Operators":
    check -p1 ~= point(-1, -2, -3)
    check -p2 ~= point(1, 2, 3)
    check -p3 ~= point(0, 0, 0)
    check -p4 ~= point(-2, -4)
    check -p5 ~= point(-1, 0)
    check -p6 ~= point(1, 1)

    check (p1 + cast[Vec3](p2)) ~= point(0, 0, 0)
    check (p3 + cast[Vec3](p1)) ~= point(1, 2, 3)
    check (p5 + cast[Vec2](p6)) ~= point(0, -1)

    check (p2 - p3) ~= vec(-1, -2, -3)
    check (p4 - p5) ~= vec(1, 4)
    check (p6 - p4) ~= vec(-3, -5)

    check 2*p1 ~= point(2, 4, 6)
    check 2*p2 ~= point(-2, -4, -6)
    check 2*p3 ~= point(0, 0, 0)
    check 2*p4 ~= point(4, 8)
    check 2*p5 ~= point(2, 0)
    check 2*p6 ~= point(-2, -2)
