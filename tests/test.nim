import std/[unittest, options, math], ngm, ngm/pga, ngm/complex

# TODO: randomized tests

suite "General":
    test "Interpolation":
        check:
            step(0.1) =~ 0
            step(1.1) =~ 1
            # step(0.1, 0.0..10.0) == 0
            # step(11, 0.0..10.0) == 10

    test "Angles":
        let r1 = 2.13'rad
        let r2 = 0.14'rad
        let d1 = 172'deg
        let d2 = 37'°
        check:
            122.04001036286535'deg =~ deg r1
            8.021409131831525'deg  =~ deg r2

            3.001966313430247'rad  =~ rad d1
            0.6457718232379019'rad =~ rad d2

        check:
            lerp(r1, r2, 0.5) == rad (2.13*0.5 + 0.14*0.5)
            lerp(d1, d2, 0.5) == deg (172*0.5 + 37*0.5)
            lerp(r1, r2, 0.3) == rad (2.13*0.7 + 0.14*0.3)
            lerp(d1, d2, 0.7) == deg (172*0.3 + 37*0.7)

suite "Rect":
    include rect

suite "Vectors":
    include vector

suite "Matrices":
    include matrix

suite "Quaternions":
    include quat

suite "Dual Quaternions":
    include dquat

suite "PGA":
    include pga

suite "Complex":
    include complex

suite "Colours":
    include colours
