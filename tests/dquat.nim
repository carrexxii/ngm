var
    q1 = dquat(quat(1, 1, 1, 1), quat(5, 6, 7, 0))
    q2 = dquat(quat(1, 0, 1, 1), quat(1, 1, 1, 0))
    q3 = DQuatIdent

test "Stringify":
    check:
        $q1 == "[(0.5, 0.5, 0.5, 0.5); (5.0, 6.0, 7.0, 0.0)]"
        $q2 == "[(0.57735026, 0.0, 0.57735026, 0.57735026); (1.0, 1.0, 1.0, 0.0)]"
        $q3 == "[(0.0, 0.0, 0.0, 1.0); (0.0, 0.0, 0.0, 0.0)]"

        q1.repr == "DQuat [real: Quat (x: 0.5, y: 0.5, z: 0.5, w: 0.5); dual: Quat (x: 5.0, y: 6.0, z: 7.0, w: 0.0)]"
        q2.repr == "DQuat [real: Quat (x: 0.57735026, y: 0.0, z: 0.57735026, w: 0.57735026); dual: Quat (x: 1.0, y: 1.0, z: 1.0, w: 0.0)]"
        q3.repr == "DQuat [real: Quat (x: 0.0, y: 0.0, z: 0.0, w: 1.0); dual: Quat (x: 0.0, y: 0.0, z: 0.0, w: 0.0)]"
