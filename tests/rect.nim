var
    r1 = rect(10, 10, 80, 30)
    r2 = rect(10, 0, 30, 80)
    r3 = rect(50, 50, 10, 10)
    r4 = rect(100, 100, 10, 10)

test "Stringify":
    check:
        $r1 == "[10.0, 10.0, 80.0, 30.0]"
        $r2 == "[10.0, 0.0, 30.0, 80.0]"
        $r3 == "[50.0, 50.0, 10.0, 10.0]"
        $r4 == "[100.0, 100.0, 10.0, 10.0]"

test "Rects":
    check:
        r1.x == 10
        r2.y == 0
        r3.w == 10
        r4.h == 10
        r4.x == 100
        r4.y == 100

        r1.xy == vec(10, 10)
        r2.wh == vec(30, 80)
        r3.xh == vec(50, 10)

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

    var r = rect(0, 0, 0, 0)
    r.x = 10
    r.y = 20
    r.w = 30
    r.h = 40
    check: r == rect(10, 20, 30, 40)
    r.xy = vec(66, 99)
    check: r == rect(66, 99, 30, 40)
    r.x -= 15
    check: r == rect(51, 99, 30, 40)
