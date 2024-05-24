from std/strformat import `&`

const
    SrcDir  = "./n3d"
    LibDir  = "./lib"
    TestDir = "./tests"

task restore, "Fetch CGLM":
    mkdir &"{SrcDir}/cglm"
    exec &"git submodule update --init --remote --merge --recursive -j 8"
    exec &"cp -r {LibDir}/cglm/include/cglm {SrcDir}/"

task test, "Run tests":
    exec &"nim c -r -p:. -o:test {TestDir}/main.nim"
    rm_file "./test"
