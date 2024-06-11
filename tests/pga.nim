import "../ngm/pga"
from std/strformat import `&`

let x = 1'e1
let y = 2'e2

assert &"{x}, {y}" == "1.0e1, 2.0e2"
assert &"{1'e1}, {2'e2}" == "1.0e1, 2.0e2"
