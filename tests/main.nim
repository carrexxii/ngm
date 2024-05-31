import ngm
from std/strformat import `&`

var
    v = Vec3Zero
    u = vec(1, 2, 3)
    w = vec(3, 5, 7)

echo &"v = {v}, u = {u}, w = {w}"
echo &"{v} + {u} = {v + u}"
echo &"{w} - {u} = {w - u}"
