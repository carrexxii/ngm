import std/enumerate
from std/os import `/`
from std/strformat import `&`
export enumerate, `&`, `/`

const CGLMDir* {.strdefine.} = "../lib/cglm/include/cglm"
const CGLMHeader* = CGLMDir / "cglm.h"
