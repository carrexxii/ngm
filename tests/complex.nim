var
    x = 1 + 0'i
    y = complex(1, 1)
    z = complex(2, 3)
    w = -3 + 7'i
    u = 2 - 4'i

test "Stringify":
    check:
        $x ==  "1.0"
        $y ==  "1.0 + 1.0i"
        $z ==  "2.0 + 3.0i"
        $w == "-3.0 + 7.0i"
        $u ==  "2.0 - 4.0i"

    check:
        x.repr == "Complex(1.0, 0.0i)"
        y.repr == "Complex(1.0, 1.0i)"
        z.repr == "Complex(2.0, 3.0i)"
        w.repr == "Complex(-3.0, 7.0i)"
        u.repr == "Complex(2.0, -4.0i)"

test "Arithmetic":
    check:
        x + y ==  2 + 1'i
        y + z ==  3 + 4'i
        z + w == -1 + 10'i
        w + u == -1 + 3'i
        u + x ==  3 - 4'i

    check:
        x - y ==  0 - 1'i
        y - z == -1 - 2'i
        z - w ==  5 - 4'i
        w - u == -5 + 11'i
        u - x ==  1 - 4'i

    check:
        1*x ==  1  + 0'i
        2*y ==  2  + 2'i
        3*z ==  6  + 9'i
        4*w == -12 + 28'i
        5*u ==  10 - 20'i

    check:
        (3 + 5'i)*(2 + 3'i) == -9 + 19'i
        x*y ==  1  + 1'i
        y*z == -1  + 5'i
        z*w == -27 + 5'i
        w*u ==  22 + 26'i
        u*x ==  2  - 4'i

    check:
        (3 + 5'i)/(2 + 3'i) =~ 21/13 + 1'i/13
        x/y =~  1/2   - 0.5'i
        y/z =~  5/13  - 1'i/13
        z/w =~  15/58 - 23'i/58
        w/u =~ -17/10 + 1'i/10
        u/x =~  2     - 4'i

test "":
    check:
        x.normalised.mag =~ 1.0f
        y.normalised.mag =~ 1.0f
        z.normalised.mag =~ 1.0f
        w.normalised.mag =~ 1.0f
        u.normalised.mag =~ 1.0f

test "Polar":
    check:
        x.mag =~ 1.0f      ; x.arg =~ rad arctan2( 0.0f,  1)
        y.mag =~ sqrt 2.0f ; y.arg =~ rad arctan2( 1.0f,  1)
        z.mag =~ sqrt 13.0f; z.arg =~ rad arctan2( 3.0f,  2)
        w.mag =~ sqrt 58.0f; w.arg =~ rad arctan2( 7.0f, -3)
        u.mag =~ sqrt 20.0f; u.arg =~ rad arctan2(-4.0f,  2)
