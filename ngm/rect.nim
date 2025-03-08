# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import common, vector

type
    ARect*[T] = distinct array[4, T]

    RectF32* = ARect[float32]
    RectF64* = ARect[float64]

    RectI16* = ARect[int16]
    RectI32* = ARect[int32]
    RectI64* = ARect[int64]
    RectU16* = ARect[uint16]
    RectU32* = ARect[uint32]
    RectU64* = ARect[uint64]

    Rect* = RectF32

func `[]`*[T](r: ARect[T]; i: SomeInteger): T           = array[4, T](r)[i]
func `[]`*[T](r: var ARect[T]; i: SomeInteger): var T   = cast[ptr UncheckedArray[T]](r.addr)[i]
func `[]=`*[T](r: var ARect[T]; i: SomeInteger; val: T) = array[4, T](r)[i] = val

func to_arr*[T](r: ARect[T]): array[4, T] = array[4, T] r

const VectorFields = ["xywh"]
type Swizzleable = ARect
include swizzle

func `$`*(r: ARect): string = &"[{r.x}, {r.y}, {r.w}, {r.h}]"

#[ -------------------------------------------------------------------- ]#

{.push inline.}

func frect*(x, y, w, h: distinct SomeNumber): RectF32   = RectF32 [float32 x, float32 y, float32 w, float32 h]
func drect*(x, y, w, h: distinct SomeNumber): RectF64   = RectF64 [float64 x, float64 y, float64 w, float64 h]
func recti16*(x, y, w, h: distinct SomeNumber): RectI16 = RectI16 [int16 x, int16 y, int16 w, int16 h]
func recti32*(x, y, w, h: distinct SomeNumber): RectI32 = RectI32 [int32 x, int32 y, int32 w, int32 h]
func recti64*(x, y, w, h: distinct SomeNumber): RectI64 = RectI64 [int64 x, int64 y, int64 w, int64 h]
func rectu16*(x, y, w, h: distinct SomeNumber): RectU16 = RectU16 [uint16 x, uint16 y, uint16 w, uint16 h]
func rectu32*(x, y, w, h: distinct SomeNumber): RectU32 = RectU32 [uint32 x, uint32 y, uint32 w, uint32 h]
func rectu64*(x, y, w, h: distinct SomeNumber): RectU64 = RectU64 [uint64 x, uint64 y, uint64 w, uint64 h]
func rect*(x, y, w, h: distinct SomeNumber): Rect = frect x, y, w, h

func frect*[T](r: ARect[T]): RectF32   = RectF32 [float32 r.x, float32 r.y, float32 r.w, float32 r.h]
func drect*[T](r: ARect[T]): RectF64   = RectF64 [float64 r.x, float64 r.y, float64 r.w, float64 r.h]
func recti16*[T](r: ARect[T]): RectI16 = RectI16 [int16 r.x, int16 r.y, int16 r.w, int16 r.h]
func recti32*[T](r: ARect[T]): RectI32 = RectI32 [int32 r.x, int32 r.y, int32 r.w, int32 r.h]
func recti64*[T](r: ARect[T]): RectI64 = RectI64 [int64 r.x, int64 r.y, int64 r.w, int64 r.h]
func rectu16*[T](r: ARect[T]): RectU16 = RectU16 [uint16 r.x, uint16 r.y, uint16 r.w, uint16 r.h]
func rectu32*[T](r: ARect[T]): RectU32 = RectU32 [uint32 r.x, uint32 r.y, uint32 r.w, uint32 r.h]
func rectu64*[T](r: ARect[T]): RectU64 = RectU64 [uint64 r.x, uint64 r.y, uint64 r.w, uint64 r.h]
func rect*[T](r: ARect[T]): Rect = frect r

func rect_from_corners*[T](p1, p2: AVec2[T]): ARect[T] =
    ## The vertices are reordered to get a positive size
    let (x, w) = if p1.x < p2.x: (p1.x, p2.x - p1.x) else: (p2.x, p1.x - p2.x)
    let (y, h) = if p1.y < p2.y: (p1.y, p2.y - p1.y) else: (p2.y, p1.y - p2.y)
    ARect[T] [x, y, w, h]

func rect_from_pos_and_size*[T](pos, sz: AVec2[T]): ARect[T] =
    ARect[T] [pos.x, pos.y, sz.x, sz.y]

func to_vtxs*[T](r: ARect[T]): array[4, AVec2[T]] =
    [[r.x      , r.y      ],
     [r.x      , r.y + r.h],
     [r.x + r.w, r.y + r.h],
     [r.x + r.w, r.y      ]]

func trunc*[T](r: ARect[T]): ARect[T] = ARect[T] [trunc r.x, trunc r.y, trunc r.w, trunc r.h]
func round*[T](r: ARect[T]): ARect[T] = ARect[T] [round r.x, round r.y, round r.w, round r.h]

func `==`*[T](r1, r2: ARect[T]): bool = (r1.x == r2.x) and (r1.y == r2.y) and (r1.w == r2.w) and (r1.h == r2.h)
func `=~`*[T](r1, r2: ARect[T]): bool = (r1.x =~ r2.x) and (r1.y =~ r2.y) and (r1.w =~ r2.w) and (r1.h =~ r2.h)

func `+`*[T](r: ARect[T]; v: Vec2): ARect[T] =
    ## Add `v` to the rect's position
    ARect[T] [r.x + v.x, r.y + v.y, r.w, r.h]
func `-`*[T](r: ARect[T]; v: Vec2): ARect[T] =
    ## Subtracts `v` from the rect's position
    ARect[T] [r.x - v.x, r.y - v.y, r.w, r.h]
func `*`*[T](r: ARect[T]; s: float32): ARect[T] = # TODO: fix s's type
    ## Multiplies the size of the rect by `s`
    ARect[T] [r.x, r.y, s*r.w, s*r.h]
func `/`*[T](r: ARect[T]; s: float32): ARect[T] =
    ## Divides the size of the rect by `s`
    ARect[T] [r.x, r.y, r.w/s, r.h/s]

func `*`*[T](s: float32; r: ARect[T]): ARect[T] = r * s

func `+=`*[T](r: var ARect[T]; v: AVec2[T])   = r = r + v
func `-=`*[T](r: var ARect[T]; v: AVec2[T])   = r = r - v
func `*=`*[T](r: var ARect[T]; s: SomeNumber) = r = r * T s
func `/=`*[T](r: var ARect[T]; s: SomeNumber) = r = r / T s

func intersection*[T](r1, r2: ARect[T]): ARect[T] =
    let x1 = max(r1.x       , r2.x)
    let y1 = max(r1.y       , r2.y)
    let x2 = min(r1.x + r1.w, r2.x + r2.w)
    let y2 = min(r1.y + r1.h, r2.y + r2.h)
    if x1 < x2 and y1 < y2:
        ARect[T] [x1, y1, x2 - x1, y2 - y1]
    else:
        default ARect[T]

func union*[T](r1, r2: ARect[T]): ARect[T] =
    let x1 = min(r1.x       , r2.x)
    let y1 = min(r1.y       , r2.y)
    let x2 = max(r1.x + r1.w, r2.x + r2.w)
    let y2 = max(r1.y + r1.h, r2.y + r2.h)
    ARect[T] [x1, y1, x2 - x1, y2 - y1]

func `∩`*[T](r1, r2: ARect[T]): ARect[T] = intersection r1, r2
func `∪`*[T](r1, r2: ARect[T]): ARect[T] = union r1, r2

func intersects*[T](r1, r2: ARect[T]): bool =
    (r1.x + r1.w > r2.x) and (r1.x < r2.x + r2.w) and
    (r1.y + r1.h > r2.y) and (r1.y < r2.y + r2.h)

func contains*[T](r: ARect[T]; p: AVec2[T]): bool =
    (p.x >= r.x) and (p.x <= r.x + r.w) and
    (p.y >= r.y) and (p.y <= r.y + r.h)

func centred*[T](r: ARect[T]): ARect[T] =
    ARect[T] [r.x + T (0.5*float r.w),
              r.y + T (0.5*float r.h),
              r.w, r.h]
func centre*[T](r: var ARect[T]) = r = centred r

func vcentred*[T](r: ARect[T]; min, max: SomeNumber): ARect[T] =
    result = r
    result.y = T(min + 0.5*(max - min)) - 0.5*r.h
func vcentred*[T](r: ARect[T]; range: Slice[T]): ARect[T] = r.vcentred range.a, range.b
func vcentre*[T](r: var ARect[T]; min, max: SomeNumber)   = r = r.vcentred(min, max)
func vcentre*[T](r: var ARect[T]; range: Slice[T])        = r = r.vcentred range

func hcentred*[T](r: ARect[T]; min, max: SomeNumber): ARect[T] =
    result = r
    result.x = T(min + 0.5*(max - min)) - 0.5*r.w
func hcentred*[T](r: ARect[T]; range: Slice[T]): ARect[T] = r.hcentred range.a, range.b
func hcentre*[T](r: var ARect[T]; min, max: SomeNumber)   = r = r.hcentred(min, max)
func hcentre*[T](r: var ARect[T]; range: Slice[T])        = r = r.hcentred range

# TODO: test swizzle replacement
func expanded*[T](r: ARect[T]; v: AVec2): ARect[T] =
    ARect[T] [r.x - T v.x, r.y - T v.y,
              r.w + T v.x, r.h + T v.y]
func expand*[T](r: var ARect[T]; v: AVec2) = r = r.expanded v

func area*[T](r: ARect[T]): T = r.w * r.h

func bottom_right*[T](r: ARect[T]; sz: AVec2[T]): ARect[T] = rect(r.x + r.w - sz.x, r.y + r.h - sz.y, sz.x, sz.y)

{.pop.}
