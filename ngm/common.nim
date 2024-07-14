# This file is a part of NGM. Copyright (C) 2024 carrexxii.
# It is distributed under the terms of the Apache License, Version 2.0.
# For a copy, see the LICENSE file or <https://apache.org/licenses/>.

import std/[sugar, enumerate]
from std/os        import `/`, `/../`, parent_dir
from std/strformat import `&`
export sugar, enumerate, `&`, `/`

const CGLMDir* = current_source_path.parent_dir() /../ "lib/cglm/include/cglm/"
const CGLMInclude* = &"""
#define CGLM_FORCE_DEPTH_ZERO_TO_ONE
#define CGLM_FORCE_LEFT_HANDED
"""

