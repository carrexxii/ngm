import std/math, common, util

{.push inline.}

func lerp*(a, b, t: Real): Real =
    a + t*(b - a)

func step*(x: Real; r = (SomeNumber 0)..(SomeNumber 1)): Real =
    if x < Real r.b:
        Real r.a
    else:
        Real r.b

func ease_in*(x: Real; exp = 2): Real  = x^exp
func ease_out*(x: Real; exp = 2): Real = 1 - (1 - x)^exp
func ease_in_out*(x: Real; exp = 2): Real =
    if x < 0.5:
        2*x^exp
    else:
        1 - 0.5*(-2*x + 2)^exp

func ease_in_sine*(x: Real): Real     = 1 - cos(π÷2*x)
func ease_out_sine*(x: Real): Real    = sin(π÷2*x)
func ease_in_out_sine*(x: Real): Real = 0.5 - 0.5*cos(x*π)

func ease_in_circular*(x: Real): Real  = 1 - sqrt(1 - x^2)
func ease_out_circular*(x: Real): Real = sqrt(1 - (x - 1)^2)
func ease_in_out_circular*(x: Real): Real =
    if x < 0.5:
        0.5 - 0.5*sqrt(1 - 4*x^2)
    else:
        0.5*sqrt(1 - (-2*x + 2)^2)

const
    BackC1: Real = 1.70158
    BackC2: Real = BackC1*1.525
    BackC3: Real = BackC1 + 1
func ease_in_back*(x: Real): Real  = BackC3*x^3 - BackC1*x^2
func ease_out_back*(x: Real): Real = 1 + BackC3*(x - 1)^3 + BackC1*(x - 1)^2
func ease_in_out_back*(x: Real): Real =
    const c = BackC2 + 1
    if x < 0.5:
        2*x^2*(2*c*x - BackC2)
    else:
        0.5*(2*x - 2)^2*(c*(2*x - 2) + BackC2) + 1

const ElasticC1 = 2*π/3
const ElasticC2 = 2*π/4.5
func ease_in_elastic*(x: Real): Real =
    if x == 0:
        0
    elif x == 1:
        1
    else:
        const c1 = 10*ElasticC1
        const c2 = 10.75*ElasticC1
        -2.pow(10*x - 10)*sin(c1*x - c2)
func ease_out_elastic*(x: Real): Real =
    if x == 0:
        0
    elif x == 1:
        1
    else:
        const c1 = 10*ElasticC1
        const c2 = 0.75*ElasticC1
        2.pow(-10*x)*sin(c1*x - c2) + 1;
func ease_in_out_elastic*(x: Real): Real =
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

func ease_out_bounce*(x: Real): Real =
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
func ease_in_bounce*(x: Real): Real =
    1 - ease_out_bounce(1 - x)
func ease_in_out_bounce*(x: Real): Real =
    if x < 0.5:
        0.5 - 0.5*ease_out_bounce(1 - 2*x)
    else:
        0.5 + 0.5*ease_out_bounce(2*x - 1)

#[ -------------------------------------------------------------------- ]#

func lerp*(a, b: Radians; t: Real): Radians {.borrow.}
func lerp*(a, b: Degrees; t: Real): Degrees {.borrow.}

{.pop.}
