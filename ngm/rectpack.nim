# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

## Skyline rect packing

import std/[options, enumerate], common, rect, vector

type RectPacker*[T: SomeNumber] = object
    skyline*: seq[AVec2[T]]
    sz*     : AVec2[T]

func create_rect_packer*[T: SomeNumber](sz: AVec2[T]): RectPacker[T] =
    result = RectPacker[T](
        skyline: new_seq_of_cap[AVec2[T]] 32,
        sz     : sz,
    )
    result.skyline.add [T 0, 0]

func pack*[T: SomeNumber](rp: var RectPacker[T]; sz: AVec2[T]): Option[ARect[T]] =
    if sz.x <= 0 or sz.y <= 0:
        return none ARect[T]

    # Best/target values
    var idx  = high int
    var idx2 = high int
    var pos  = AVec2[T].high

    for (i, l) in enumerate rp.skyline:
        var x = l.x
        var y = l.y
        # Make sure we don't overflow the packer's bounds
        if sz.x > rp.sz.x - x:
            break
        # Skip if this would raise our y-pos
        if y >= pos.y:
            continue

        # This expands the rect over multiple skylines until it fits
        var i2 = i + 1
        while i2 < rp.skyline.len:
            let p = rp.skyline[i2]
            # Check if we actually reach the next skyline
            if x + sz.x <= p.x:
                break
            # Raise `y` so it doesn't intersect
            if y < p.y:
                y = p.y
            inc i2

        # We only use the new position if it is lower and
        # we don't overflow the packer's bounds
        if y >= pos.y or sz.y > rp.sz.y - y:
            continue

        idx  = i
        idx2 = i2
        pos  = vec(x, y)

    if idx == high int:
        return none ARect[T]
    ngm_assert idx < idx2, &"{idx} < {idx2}"

    # Now that the rect has been placed, we raise the strip and correct the skyline
    var lpt = vec(pos.x, pos.y + sz.y)
    var rpt = vec(pos.x + sz.x, pos.y)
    for i in 0..<(idx2 - idx):
        if i >= rp.skyline.len:
            break
        rp.skyline.delete idx

    rp.skyline.insert lpt, idx
    rp.skyline.insert rpt, idx + 1

    return some ARect[T] [pos.x, pos.y, sz.x, sz.y]
