# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

##
## Note: Unless both 2D and 3D methods/elements are provided, assume it is for 3D PGA.
##
## ### Basis Vectors
## - 2D PGA $\\quad e_1,~ e_2,~ e_0,~ e_{01},~ e_{20},~ e_{12},~ e_{012}$
## - 3D PGA $\\quad e_1,~ e_2,~ e_3,~ e_0,~ e_{01},~ e_{02},~ e_{03},~ e_{23},~ e_{31},~ e_{12},~ e_{023},~ e_{031},~ e_{012},~ e_{321},~ e_{0123}$
##
## ### PGA Elements
## | Element             | Equivalent          | Grade | Equation                                                                                                                                                                                                               |
## | ---                 | ---                 | ---   | ---                                                                                                                                                                                                                    |
## | Scalar / Antiscalar | Magnitude           | 0 / 4 | $$\\mathbf{z} = x\\mathbf{1} + y𝟙 \\\\ \\text{or} \\\\ \\quad\\mathbf{z} = x + ye_{0123}$$                                                                                                                             |
## | Vector              | Point               | 1     | $$\\mathbf{p} = p_xe_1 + p_ye_2 + p_ze_3 + p_we_0$$                                                                                                                                                                    |
## | Bivector            | Line                | 2     | $$\\begin{aligned}\\mathbf{l} &= l_v + l_m \\\\ \\mathbf{l} &= l_{vx}e_{01} + l_{vy}e_{02} + l_{vz}e_{03} + \\\\ &\\qquad l_{mx}e_{23} + l_{my}e_{31} + l_{mz}e_{12}\\end{aligned}$$                                   |
## | Trivector           | Plane               | 3     | $$\\mathbf{g} = g_xe_{023} + g_ye_{031} + g_ze_{012} + g_we_{321}$$                                                                                                                                                    |
## | Motor               | Dual Quaternion     | N/a   | $$\\begin{aligned}\\mathbf{Q} &= Q_v + Q_m \\\\ \\mathbf{Q} &= Q_{vx}e_{01} + Q_{vy}e_{02} + Q_{vz}e_{03} + Q_{vw}e_{0123} + \\\\ &\\qquad Q_{mx}e_{23} + Q_{my}e_{31} + Q_{mz}e_{12} + Q_{mw}e_{0123}\\end{aligned}$$ |
## | Flector             | Reflection Operator | N/a   | $$\\begin{aligned}\\mathbf{F} &= F_p + F_g \\\\ \\mathbf{F} &= F_{px}e_1 + F_{py}e_2 + F_{pz}e_3 + F_{pw}e_0 + \\\\ &\\qquad F_{gx}e_{023} + F_{gy}e_{031} + F_{gz}e_{012} + F_{gw}e_{321}\\end{aligned}$$             |
##
## ### Symbols Used
## | Symbol | Meaning                                 | Functions     | Operators | Meaning                                                                        |
## | ---    | ---                                     | ---           | ---       | ---                                                                            |
## | `∧`    | Wedge / Exterior product / Join         | [wedge]       | [`∧`]     |                                                                                |
## | `∨`    | Antiwedge / Exterior antiproduct / Meet | [antiwedge]   | [`∨`]     |                                                                                |
## | `●`    | Bulk                                    | [bulk]        |           | The real/non-$e_0$ parts of the element                                        |
## | `○`    | Weight                                  | [weight]      |           | The extent of the element into the 4th dimension (i.e., those including $e_0$) |
## | `★`    | Bulk dual                               | [bulk_dual]   | [`★`]     |                                                                                |
## | `☆`    | Weight dual                             | [weight_dual] | [`★~`]    |                                                                                |
##
## ### List of Useful Expressions
## | Expression     | Interpretation                                         |
## | ---            | ---                                                    |
## | `g ∨ l`        | Construct a point where `g` and `l` intersect          |
## | `p ∧ q`        | Construct a line from `p` to `q`                       |
## | `g ∨ h`        | Construct a line where `g` and `h` intersect           |
## | `p ∧ g☆`       | Construct a line through `p orthogonal to `g`          |
## | `l ∧ p`        | Construct a plane containing `l` and `p`               |
## | `p ∧ l☆`       | Construct a plane containing `p` and orthogonal to `l` |
## | `l ∧ g☆`       | Construct a plane containing `l` and orthogonal to `g` |
## | `g ∨ (p ∧ g☆)` | Orthogonally project `p` onto `g`                      |
## | `l ∨ (p ∧ l☆)` | Orthogonally project `p` onto `l`                      |
## | `g ∨ (l ∧ g☆)` | Orthogonally project `l` onto `g`                      |
## | `g ∨ (p ∧ g★)` | Centrally project `p` onto `g`                         |
## | `l ∨ (p ∧ l★)` | Centrally project `p` onto `l`                         |
## | `g ∨ (l ∧ g★)` | Centrally project `l` onto `g`                         |
##

import common, util, geometry, vector, matrix

type
    Bivec2D* = object
        x*: Real ## $l_xe_{01}$
        y*: Real ## $l_ye_{20}$
        w*: Real ## $l_we_{12}$
    Bivec3D* = object
        v*: Vec3 ## $v_xe_{01} + v_ye_{02} + v_ze_{03}$
        m*: Vec3 ## $m_xe_{23} + m_ye_{31} + m_ze_{12}$

    Trivec3D* = object
        x*: Real ## $g_xe_{023}$
        y*: Real ## $g_ye_{031}$
        z*: Real ## $g_ze_{012}$
        w*: Real ## $g_we_{321}$

    Antiscalar2D* = Real ## $e_{012}$
    Antiscalar3D* = Real ## $e_{0123}$

    Motor* = object
        v*: Vec4 ## $v_xe_{01} + v_ye_{02} + v_ze_{03} + v_we_{0123}$
        m*: Vec4 ## $m_xe_{23} + m_ye_{31} + m_ze_{12} + m_we_{0123}$

    Flector* = object
        p*: Vec4 ## $p_xe_1 + p_ye_2 + p_ze_3 + p_we_0$
        g*: Vec4 ## $g_xe_{023} + g_ye_{031} + g_ze_{012} + g_we_{321}$

{.push inline.}

func bivec*(x, y, w: Real): Bivec2D                = Bivec2D(x: x, y: y, w: w)
func bivec*(vx, vy, vz, mx, my, mz: Real): Bivec3D = Bivec3D(v: [vx, vy, vz], m: [mx, my, mz])
func trivec*(x, y, z, w: Real): Trivec3D           = Trivec3D(x: x, y: y, z: z, w: w)

func bivec*(v: Vec3): Bivec2D    = bivec v.x, v.y, v.w
func bivec*(v, m: Vec3): Bivec3D = bivec v.x, v.y, v.z, m.x, m.y, m.z
func trivec*(v: Vec4): Trivec3D  = trivec v.x, v.y, v.z, v.w

when defined Ngm2D:
    type
        Bivec*      = Bivec2
        Antiscalar* = Antiscalar2
elif defined Ngm3D:
    type
        Bivec*      = Bivec3D
        Trivec*     = Trivec3D
        Antiscalar* = Antiscalar3D

func bulk*(p: Vec4    ): Vec4     = [p.x, p.y, p.z, 0]
func bulk*(p: Point3D ): Vec4     = [p.x, p.y, p.z, 0]
func bulk*(l: Bivec3D ): Bivec3D  = bivec Vec3Zero, l.m
func bulk*(g: Trivec3D): Trivec3D = trivec 0, 0, 0, g.w

func weight*(p: Vec4    ): Vec4     = Vec4 [Real 0, 0, 0, p.w]
func weight*(p: Point3D ): Vec4     = Vec4 [Real 0, 0, 0, 1]
func weight*(l: Bivec3D ): Bivec3D  = bivec l.v, Vec3Zero
func weight*(g: Trivec3D): Trivec3D = trivec g.x, g.y, g.z, 0

func bulk_dual*(p: Vec4    ): Trivec3D = trivec p.x, p.y, p.z, 0
func bulk_dual*(p: Point3D ): Trivec3D = trivec p.x, p.y, p.z, 0
func bulk_dual*(l: Bivec3D ): BiVec3D  = bivec Vec3Zero, -l.m
func bulk_dual*(g: Trivec3D): Vec4     = [Real 0, 0, 0, -g.w]

func weight_dual*(p: Vec4    ): Trivec3D = trivec Real 0, 0, 0, p.w
func weight_dual*(p: Point3D ): Trivec3D = trivec Real 0, 0, 0, 1
func weight_dual*(l: Bivec3D ): BiVec3D  = bivec -l.v, Vec3Zero
func weight_dual*(g: Trivec3D): Vec4     = [-g.x, -g.y, -g.z, 0]

func bulk_norm*(p: Vec4    ): Real = norm p.xyz
func bulk_norm*(p: Point3D ): Real = norm p
func bulk_norm*(l: Bivec3D ): Real = norm l.m
func bulk_norm*(g: Trivec3D): Real = abs g.w

func weight_norm*(p: Vec4    ): Antiscalar3D = AntiScalar3D abs p.w
func weight_norm*(p: Point3D ): Antiscalar3D = AntiScalar3D 1
func weight_norm*(l: Bivec3D ): Antiscalar3D = AntiScalar3D norm l.v
func weight_norm*(g: Trivec3D): Antiscalar3D = AntiScalar3D norm [g.x, g.y, g.z]

func attitude*(p: Vec4    ): Real    = p.w
func attitude*(p: Point3D ): Real    = 1
func attitude*(l: Bivec3D ): Vec4    = [l.v.x, l.v.y, l.v.z, 0]
func attitude*(g: Trivec3D): Bivec3D = bivec Vec3Zero, [g.x, g.y, g.z]

func right_complement*(p: Vec4    ): Trivec3D = trivec p
func right_complement*(p: Point3D ): Trivec3D = trivec p.x, p.y, p.z, 1
func right_complement*(l: Bivec3D ): BiVec3D  = bivec -l.m, -l.v
func right_complement*(g: Trivec3D): Vec4     = -[g.x, g.y, g.z, g.w]

func `★`*(p: Vec4    ): Trivec3D = bulk_dual p
func `★`*(p: Point3D ): Trivec3D = bulk_dual p
func `★`*(l: Bivec3D ): BiVec3D  = bulk_dual l
func `★`*(g: Trivec3D): Vec4     = bulk_dual g

func `★~`*(p: Vec4    ): Trivec3D = weight_dual p
func `★~`*(p: Point3D ): Trivec3D = weight_dual p
func `★~`*(l: Bivec3D ): BiVec3D  = weight_dual l
func `★~`*(g: Trivec3D): Vec4     = weight_dual g

func wedge*(p, q: Vec3): Bivec2D =
    ## $$
    ## \begin{aligned}
    ## p \wedge q &= (p_xe_1 + p_ye_2 + p_we_0) \wedge (q_xe_1 + q_ye_2 + q_we_0) \\
    ##            &= p_xq_xe_1e_1 + p_xq_ye_1e_2 + p_xq_we_1e_0 + \\
    ##       &\qquad p_yq_xe_2e_1 + p_yq_ye_2e_2 + p_yq_we_2e_0 + \\
    ##       &\qquad p_wq_xe_0e_1 + p_wq_ye_0e_2 + p_wq_we_0e_0 \\
    ##            &= p_xq_ye_{12} + p_xq_we_{10} + p_yq_xe_{21} + p_yq_we_{20} + p_wq_xe_{01} + p_wq_ye_{02} \\
    ##            &= (p_wq_x - p_xq_w)e_{01} + (p_yq_w - p_wq_y)e_{20} + (p_xq_y - p_yq_x)e_{12}
    ## \end{aligned}
    ## $$
    bivec p.w*q.x - p.x*q.w,
          p.y*q.w - p.w*q.y,
          p.x*q.y - p.y*q.x

func wedge*(p, q: Point2D): Bivec2D =
    ## $l = p \\wedge q$
    bivec q.x - p.x,
          p.y - q.y,
          p.x*q.y - p.y*q.x

func wedge*(p, q: Vec4): Bivec3D =
    ## $$
    ## \begin{aligned}
    ## p \wedge q &= (p_xe_1 + p_ye_2 + p_ze_3 + p_we_0) \wedge (q_xe_1 + q_ye_2 + q_ze_3 + q_we_0) \\
    ##            &= p_xe_1q_xe_1 + p_xe_1q_ye_2 + p_xe_1q_ze_3 + p_xe_1q_we_0 + \\
    ##       &\qquad p_ye_2q_xe_1 + p_ye_2q_ye_2 + p_ye_2q_ze_3 + p_ye_2q_we_0 + \\
    ##       &\qquad p_ze_3q_xe_1 + p_ze_3q_ye_2 + p_ze_3q_ze_3 + p_ze_3q_we_0 + \\
    ##       &\qquad p_we_0q_xe_1 + p_we_0q_ye_2 + p_we_0q_ze_3 + p_we_0q_we_0 \\
    ##            &= p_xq_x + p_xq_ye_{12} + p_xq_ze_{13} + p_xq_we_{10} + \\
    ##       &\qquad p_yq_xe_{21} + p_yq_y + p_yq_ze_{23} + p_yq_we_{20} + \\
    ##       &\qquad p_zq_xe_{31} + p_zq_ye_{32} + p_zq_z + p_zq_we_{30} + \\
    ##       &\qquad p_wq_xe_{01} + p_wq_ye_{02} + p_wq_ze_{03} \\
    ##            &= (p_yq_z - p_zq_y)e_{23} + (p_zq_x - p_xq_z)e_{31} + (p_xq_y - p_yq_x)e_{12} + \\
    ##       &\qquad (p_wq_x - p_xq_w)e_{01} + (p_wq_y - p_yq_w)e_{02} + (p_wq_z - p_zq_w)e_{03} + \\
    ##       &\qquad p_xq_x + p_yq_y + p_zq_z
    ## \end{aligned}
    ## $$
    bivec [p.w*q.x - p.x*q.w,
           p.w*q.y - p.y*q.w,
           p.w*q.z - p.z*q.w],
          [p.y*q.z - p.z*q.y,
           p.z*q.x - p.x*q.z,
           p.x*q.y - p.y*q.x]

func wedge*(p, q: Point3D): Bivec3D =
    ## $l = p \\wedge q$
    bivec [q.x - p.x,
           q.y - p.y,
           q.z - p.z],
          [p.y*q.z - p.z*q.y,
           p.z*q.x - p.x*q.z,
           p.x*q.y - p.y*q.x]

func wedge*(l: Bivec3D; p: Vec4): Trivec3D =
    ## $g = l \\wedge p$
    trivec l.v.y*p.z - l.v.z*p.y + l.m.x*p.w,
           l.v.z*p.x - l.v.x*p.z + l.m.y*p.w,
           l.v.x*p.y - l.v.y*p.x + l.m.z*p.w,
          -l.m.x*p.x - l.m.y*p.y + l.m.z*p.z

func wedge*(l: Bivec3D; p: Point3D): Trivec3D =
    ## $g = l \\wedge p$
    trivec l.v.y*p.z - l.v.z*p.y + l.m.x,
           l.v.z*p.x - l.v.x*p.z + l.m.y,
           l.v.x*p.y - l.v.y*p.x + l.m.z,
          -l.m.x*p.x - l.m.y*p.y + l.m.z*p.z

func antiwedge*(g, h: Trivec3D): Bivec3D =
    ## $l = g \\vee h$
    bivec [g.z*h.y - g.y*h.z,
           g.x*h.z - g.z*h.x,
           g.y*h.x - g.x*h.y],
          [g.x*h.w - g.w*h.x,
           g.y*h.w - g.w*h.y,
           g.z*h.w - g.w*h.z]

func antiwedge*(g: Trivec3D; l: Bivec3D): Vec4 =
    ## $p = g \\vee l$
    [g.z*l.m.y - g.y*l.m.z + g.w*l.v.x,
     g.x*l.m.z - g.z*l.m.x + g.w*l.v.y,
     g.y*l.m.x - g.x*l.m.y + g.w*l.v.z,
    -g.x*l.v.x - g.y*l.v.y - g.z*l.v.z]

func `∧`*(p, q: Vec3 | Point2D): Bivec2D           = wedge p, q
func `∧`*(p, q: Vec4 | Point3D): Bivec3D           = wedge p, q
func `∧`*(l: Bivec3D; p: Vec4 | Point3D): Trivec3D = wedge l, p

func `∨`*(g, h: Trivec3D): Bivec3D       = antiwedge g, h
func `∨`*(g: Trivec3D; l: Bivec3D): Vec4 = antiwedge g, l

func oproject*(p: Point3D | Vec4; g: Trivec3D): Point3D = ##[ Orthogonally project $p$ onto $g$. ]## g ∨ (p ∧ ★~g)
func oproject*(p: Point3D | Vec4; l: Bivec3D ): Point3D = ##[ Orthogonally project $p$ onto $l$. ]## l ∨ (p ∧ ★~l)
func oproject*(l: Bivec3D       ; g: Trivec3D): Bivec3D = ##[ Orthogonally project $l$ onto $g$. ]## g ∨ (l ∧ ★~g)
func cproject*(p: Point3D | Vec4; g: Trivec3D): Point3D = ##[ Centrally project $p$ onto $g$.    ]## g ∨ (p ∧ ★g)
func cproject*(p: Point3D | Vec4; l: Bivec3D ): Point3D = ##[ Centrally project $p$ onto $l$.    ]## l ∨ (p ∧ ★l)
func cproject*(l: Bivec3D       ; g: Trivec3D): Bivec3D = ##[ Centrally project $l$ onto $g$.    ]## g ∨ (l ∧ ★g)

{.pop.}
