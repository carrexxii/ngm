var
    r1 = rect(10, 10, 80, 30)
    r2 = rect(10, 0, 30, 80)
    r3 = rect(50, 50, 10, 10)
    r4 = rect(100, 100, 10, 10)

test "Stringify":
    check:
        $r1 == "(10.0, 10.0, 80.0, 30.0)"
        $r2 == "(10.0, 0.0, 30.0, 80.0)"
        $r3 == "(50.0, 50.0, 10.0, 10.0)"
        $r4 == "(100.0, 100.0, 10.0, 10.0)"

    check:
        r1.repr == "Rect (x: 10.0, y: 10.0, w: 80.0, h: 30.0)"
        r2.repr == "Rect (x: 10.0, y: 0.0, w: 30.0, h: 80.0)"
        r3.repr == "Rect (x: 50.0, y: 50.0, w: 10.0, h: 10.0)"
        r4.repr == "Rect (x: 100.0, y: 100.0, w: 10.0, h: 10.0)"

test "Rects":
    check:
        vec(50, 25) == centre r1
        vec(25, 40) == centre r2

    check:
        rect(10, 0, 80, 80) == r1 ∪ r2

        rect(10, 10, 30, 30) == r1 ∩ r2

        r1.intersects r2
        not r3.intersects r4

        vec(10, 10)  in    r1
        vec(25, 70)  in    r2
        vec(0, 0)    notin r3
        vec(500, 50) notin r4
