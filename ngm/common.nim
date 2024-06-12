import std/[sugar, enumerate]
from std/os import `/`
from std/strformat import `&`
export sugar, enumerate, `&`, `/`

const CGLMDir* {.strdefine.} = "../lib/cglm/include/cglm"
const CGLMHeader* = CGLMDir / "cglm.h"
