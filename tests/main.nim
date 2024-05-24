import ngm
from std/strformat import `&`

var
    v = Vec3()
    u = Vec3(x:1, y:2, z:3)
    w = Vec3(x:3, y:5, z:7)

echo &"v = {v}, u = {u}, w = {w}"
echo &"{v} + {u} = {v + u}"
echo &"{w} - {u} = {w - u}"
