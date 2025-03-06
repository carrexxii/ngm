# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import std/math, common, util, quat, dquat

{.push inline.}

func lerp*[T: SomeFloat](a, b, t: T): T        = a + t*(b - a)
func lerp*[T: SomeFloat](r: Slice[T]; t: T): T = lerp r.a, r.b, t

func step*[T: SomeFloat](x: T; r = 0.0..1.0): T =
    if x < r.b:
        r.a
    else:
        r.b

func ease_in*[T: SomeFloat](x: T; exp = 2): T  = x^exp
func ease_out*[T: SomeFloat](x: T; exp = 2): T = 1 - (1 - x)^exp
func ease_in_out*[T: SomeFloat](x: T; exp = 2): T =
    if x < 0.5:
        2*x^exp
    else:
        1 - 0.5*(-2*x + 2)^exp

func ease_in_sine*[T: SomeFloat](x: T): T     = 1 - cos(x*π/2)
func ease_out_sine*[T: SomeFloat](x: T): T    = sin(x*π/2)
func ease_in_out_sine*[T: SomeFloat](x: T): T = 0.5 - 0.5*cos(x*π)

func ease_in_circular*[T: SomeFloat](x: T): T  = 1 - sqrt(1 - x^2)
func ease_out_circular*[T: SomeFloat](x: T): T = sqrt(1 - (x - 1)^2)
func ease_in_out_circular*[T: SomeFloat](x: T): T =
    if x < 0.5:
        0.5 - 0.5*sqrt(1 - 4*x^2)
    else:
        0.5*sqrt(1 - (-2*x + 2)^2)

const
    BackC1 = 1.70158
    BackC2 = BackC1*1.525
    BackC3 = BackC1 + 1
func ease_in_back*[T: SomeFloat](x: T): T  = BackC3*x^3 - BackC1*x^2
func ease_out_back*[T: SomeFloat](x: T): T = 1 + BackC3*(x - 1)^3 + BackC1*(x - 1)^2
func ease_in_out_back*[T: SomeFloat](x: T): T =
    const c = BackC2 + 1
    if x < 0.5:
        2*x^2*(2*c*x - BackC2)
    else:
        0.5*(2*x - 2)^2*(c*(2*x - 2) + BackC2) + 1

const ElasticC1 = 2*π/3
const ElasticC2 = 2*π/4.5
func ease_in_elastic*[T: SomeFloat](x: T): T =
    if x == 0:
        0
    elif x == 1:
        1
    else:
        const c1 = 10*ElasticC1
        const c2 = 10.75*ElasticC1
        -2.pow(10*x - 10)*sin(c1*x - c2)
func ease_out_elastic*[T: SomeFloat](x: T): T =
    if x == 0:
        0
    elif x == 1:
        1
    else:
        const c1 = 10*ElasticC1
        const c2 = 0.75*ElasticC1
        2.pow(-10*x)*sin(c1*x - c2) + 1;
func ease_in_out_elastic*[T: SomeFloat](x: T): T =
    if x == 0:
        0
    elif x == 1:
        1
    else:
        const c1 = 20*ElasticC2
        const c2 = 11.125*ElasticC2
        let s = sin(c1*x - c2)
        if x < 0.5:
            -0.5*2.pow(20*x - 10)*s
        else:
            0.5*2.pow(-20*x + 10)*s + 1

func ease_out_bounce*[T: SomeFloat](x: T): T =
    const c1 = 7.5625
    const c2 = 2.75
    if x < (1 / c2):
        c1*x^2
    elif x < (2 / c2):
        c1*(x - 1.5/c2)*x + 0.75
    elif x < (2.5 / c2):
        c1*(x - 2.25/c2)*x + 0.9375
    else:
        c1*(x - 2.625/c2)*x + 0.984375
func ease_in_bounce*[T: SomeFloat](x: T): T =
    1 - ease_out_bounce(1 - x)
func ease_in_out_bounce*[T: SomeFloat](x: T): T =
    if x < 0.5:
        0.5 - 0.5*ease_out_bounce(1 - 2*x)
    else:
        0.5 + 0.5*ease_out_bounce(2*x - 1)

#[ -------------------------------------------------------------------- ]#

func lerp*(a, b: Radians; t: float): Radians {.borrow.}
func lerp*(a, b: Degrees; t: float): Degrees {.borrow.}

func lerp*(q, p: DQuat; t: float32): DQuat =
    var t1 = t
    let t2 = 1 - t
    if (q ∙ p) < 0:
        t1 = -t

    [quat(q.real.x*t2 + p.real.x*t1,
          q.real.y*t2 + p.real.y*t1,
          q.real.z*t2 + p.real.z*t1,
          q.real.w*t2 + p.real.w*t1),
     quat(q.dual.x*t2 + p.dual.x*t1,
          q.dual.y*t2 + p.dual.y*t1,
          q.dual.z*t2 + p.dual.z*t1,
          q.dual.w*t2 + p.dual.w*t1)]

{.pop.}
