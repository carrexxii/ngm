var
    q1 = quat(1, 2, 3, 4)
    q2 = quat(3, 6, 9, 5)
    q3 = QuatIdent
    q4 = quat(-1, 2, -3, 1)

test "Stringify":
    check:
        $q1 == "(1.0, 2.0, 3.0, 4.0)"
        $q2 == "(3.0, 6.0, 9.0, 5.0)"
        $q3 == "(0.0, 0.0, 0.0, 1.0)"
        $q4 == "(-1.0, 2.0, -3.0, 1.0)"

    check:
        q1.repr == "Quat (x: 1.0, y: 2.0, z: 3.0, w: 4.0)"
        q2.repr == "Quat (x: 3.0, y: 6.0, z: 9.0, w: 5.0)"
        q3.repr == "Quat (x: 0.0, y: 0.0, z: 0.0, w: 1.0)"
        q4.repr == "Quat (x: -1.0, y: 2.0, z: -3.0, w: 1.0)"
