import common, borrows
from std/strutils import parse_float

type
    Degrees* = distinct float32
    Radians* = distinct float32

proc `'deg`*(x: string): Degrees {.compileTime.} = Degrees (parse_float x)
proc `'rad`*(x: string): Radians {.compileTime.} = Radians (parse_float x)

Degrees.borrow_numeric float32
Radians.borrow_numeric float32

{.push header: CGLMDir / "util.h".}
func glm_eq*(a, b: float32): bool    {.importc: "glm_eq" .}
func glm_rad*(deg: float32): float32 {.importc: "glm_rad".}
func glm_deg*(rad: float32): float32 {.importc: "glm_deg".}

func glm_lerpc*(`from`, to, t: float32): float32         {.importc: "glm_lerpc"        .}
func glm_step*(edge, x: float32): float32                {.importc: "glm_step"         .}
func glm_smooth*(t: float32): float32                    {.importc: "glm_smooth"       .}
func glm_smoothstep*(edge0, edge1, t: float32): float32  {.importc: "glm_smoothstep"   .}
func glm_smoothinterpc*(`from`, to, t: float32): float32 {.importc: "glm_smoothinterpc".}
{.pop.}

{.push inline.}

converter `Degrees -> Radians`*(x: Degrees): Radians = Radians glm_rad (float32 x)
converter `Radians -> Degrees`*(x: Radians): Degrees = Degrees glm_deg (float32 x)

func `~=`*(a, b: float32): bool = glm_eq a, b

func lerp*(`from`, to, t: float32): float32 = `from`.glm_lerpc to, t

{.pop.}
