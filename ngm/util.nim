import common

func `~=`*(a, b: float32): bool {.header: CGLMDir / "util.h", importc: "glm_eq".}

