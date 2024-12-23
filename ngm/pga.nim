# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

# ∙ ∘ × ★ ⊗ ⊘ ⊙ ⊛ ⊠ ⊡ ∩ ∧ ⊓   # same priority as * (multiplication)
# ± ⊕ ⊖ ⊞ ⊟ ∪ ∨ ⊔             # same priority as + (addition)

## Bulk: The real/non-e0 parts of the object

## Weight: The extent of the object into the 4th dimension (ie, those including e0)
##

## Points: $p_xe_1 + p_ye_2 + p_ze_3 + p_we_0$
## - A point is projected into 3D space by scaling the w coordinate to 1 (**unitization**)
##
## Lines: $v_xe_{01} + v_ye_{02} + v_ze_{03} + m_xe_{23} + m_ye_{31} + m_ze_{12}$
##
## Planes: $g_xe_{023} + g_ye_{031} + g_ze_{012} + g_we_{321}$
##

# a● = ã ⟑ 𝟙      (bulk right complement)
# a○ = a̰ ⟇ 1      (weight right complement)
# a● = 𝟙 ⟑ ã      (bulk left complement)
# a○ = 1 ⟇ a̰      (weight left complement)

import common, vector, matrix, borrows

type
    Scalar* = float32

    Vec* = object
        x*, y*, z*, w*: Scalar

    Bivec* = object
        wx*, wy*, wz*: Scalar
        yz*, zx*, xy*: Scalar

    Trivec* = object
        wyz*, wzx*, wxy*, zyx*: Scalar

    Antiscalar* = distinct Scalar

    AnyGrade = Scalar | Vec | Bivec | Trivec | Antiscalar

{.push inline.}

Antiscalar.borrow_numeric Scalar

func vec*(x, y, z: Scalar; w = Scalar 1)   : Vec    = Vec(x: x, y: y, z: z, w: w)
func bivec*(wx, wy, wz, yz, zx, xy: Scalar): Bivec  = Bivec(wx: wx, wy: wy, wz: wz, yz: yz, zx: zx, xy: xy)
func trivec*(wyz, wzx, wxy, zyx: Scalar)   : Trivec = Trivec(wyz: wyz, wzx: wzx, wxy: wxy, zyx: zyx)

func `$`*(s: Scalar)    : string = &"Scalar {float s:.2f}"
func `$`*(v: Vec)       : string = &"Vector [{v.x:.2f}, {v.y:.2f}, {v.z:.2f}, {v.w:.2f}]"
func `$`*(b: Bivec)     : string = &"Bivector [{b.wx:.2f}, {b.wy:.2f}, {b.wz:.2f}; {b.yz:.2f}, {b.zx:.2f}, {b.xy:.2f}]"
func `$`*(t: Trivec)    : string = &"Trivector [{t.wyz:.2f}, {t.wzx:.2f}, {t.wxy:.2f}, {t.zyx:.2f}]"
func `$`*(a: Antiscalar): string = &"Antiscalar {float a:.2f}"

func grade*(s: Scalar)    : int = 0
func grade*(v: Vec)       : int = 1
func grade*(b: Bivec)     : int = 2
func grade*(t: Trivec)    : int = 3
func grade*(a: Antiscalar): int = 4

func antigrade*(s: Scalar)    : int = 4
func antigrade*(v: Vec)       : int = 3
func antigrade*(b: Bivec)     : int = 2
func antigrade*(t: Trivec)    : int = 1
func antigrade*(a: Antiscalar): int = 0

func bulk*(s: Scalar)    : Scalar = s
# func bulk*(v: Vec)       : Vec3   = vec(v.x, v.y, v.z)
# func bulk*(b: Bivec)     : Vec3   = vec(b.yz, b.zx, b.xy)
func bulk*(t: Trivec)    : Scalar = t.zyx
func bulk*(a: Antiscalar): Scalar = Scalar 0

func weight*(s: Scalar)    : Scalar     = Scalar 0
func weight*(v: Vec)       : Scalar     = v.w
# func weight*(b: Bivec)     : Vec3       = vec(b.wx, b.wy, b.wz)
# func weight*(t: Trivec)    : Vec3       = vec(t.wyz, t.wzx, t.wxy)
func weight*(a: Antiscalar): Antiscalar = a

func `●`*(x: AnyGrade): auto = x.bulk
func `○`*(x: AnyGrade): auto = x.weight

{.pop.} # inline
