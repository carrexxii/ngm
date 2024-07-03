import std/[sugar, enumerate]
from std/os        import `/`, `/../`, parent_dir
from std/strformat import `&`
export sugar, enumerate, `&`, `/`

const CGLMDir* = current_source_path.parent_dir() /../ "lib/cglm/include/cglm/"
const CGLMInclude* = &"""
#define CGLM_FORCE_DEPTH_ZERO_TO_ONE
#define CGLM_FORCE_LEFT_HANDED
"""

