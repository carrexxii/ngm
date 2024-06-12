import "../ngm/pga"
from std/strformat import `&`

let
    x = 2'e1
    y = 4'e2
    z = 6'e0

echo &"Testing PGA with blades {AllBlades} and basis vectors {FullBasis}"

assert &"{x}, {y}, {z}" == "2.0e1, 4.0e2, 6.0e0"
assert &"{1'e1}, {2'e2}" == "1.0e1, 2.0e2"
assert &"{5'e12}" == "5.0e12"

assert 1'e1 + 1'e1 == 2'e1
assert 2'e1 + 4'e1 == 6'e1
assert 3'e2 + 4'e2 == 7'e2

echo 1'e0 + 1'e1
# assert $(1'e0 + 1'e1) == "1'e0 + 1'e1"
