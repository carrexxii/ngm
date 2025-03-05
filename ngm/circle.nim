# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import common, vector

type
    Circle*[T] = object
        pos*: AVec2[T]
        r*  : T

    Sphere*[T] = object
        pos*: AVec3[T]
        r*  : T
