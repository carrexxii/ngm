import std/[os, strformat, strutils, sequtils, enumerate]

let
    src_dir   = "./src"
    lib_dir   = "./lib"
    build_dir = "./build"
    test_dir  = "./tests"
    deps: seq[tuple[src, dst, tag: string; cmds: seq[string]]] = @[
        (src  : "https://github.com/recp/cglm",
         dst  : lib_dir / "cglm",
         tag  : "v0.9.4",
         cmds : @[""])
    ]

#[ -------------------------------------------------------------------- ]#

proc red    (s: string): string = &"\e[31m{s}\e[0m"
proc green  (s: string): string = &"\e[32m{s}\e[0m"
proc yellow (s: string): string = &"\e[33m{s}\e[0m"
proc blue   (s: string): string = &"\e[34m{s}\e[0m"
proc magenta(s: string): string = &"\e[35m{s}\e[0m"
proc cyan   (s: string): string = &"\e[36m{s}\e[0m"

proc error(s: string)   = echo red    &"Error: {s}"
proc warning(s: string) = echo yellow &"Warning: {s}"

var cmd_count = 0
proc run(cmd: string) =
    if defined `dry-run`:
        echo blue &"[{cmd_count}] ", cmd
        cmd_count += 1
    else:
        exec cmd

func is_git_repo(url: string): bool =
    (gorge_ex &"git ls-remote -q {url}")[1] == 0

#[ -------------------------------------------------------------------- ]#

task restore, "Fetch and build dependencies":
    run &"rm -rf {lib_dir}/*"
    run &"git submodule update --init --remote --merge -j 8"
    for dep in deps:
        if is_git_repo dep.src:
            with_dir dep.dst:
                run &"git checkout {dep.tag}"
        else:
            run &"curl -o {lib_dir / (dep.src.split '/')[^1]} {dep.src}"

        with_dir dep.dst:
            for cmd in dep.cmds:
                run cmd

task test, "Run the project's tests":
    run &"nim c -r -p:. {test_dir}/main.nim"
    # --hints:off
    # let files = (list_files test_dir).filter_it(it.ends_with ".nim")
    # for file in files:
    #     echo &"Running tests for '{file}'"
    #     run &"nim c -r --hints:off -p:. {file}"
    # run &"testament pattern \"{test_dir}/*.nim\""

task info, "Print out information about the project":
    echo green &"NGM - Nim Game Maths"
    if deps.len > 0:
        echo &"{deps.len} Dependencies:"
    for (i, dep) in enumerate deps:
        let is_git = is_git_repo dep.src
        let tag =
            if is_git and dep.tag != "":
                "@" & dep.tag
            elif is_git: "@HEAD"
            else       : ""
        echo &"    [{i + 1}] {dep.dst:<24}{cyan dep.src}{yellow tag}"

    echo ""
    run "cloc --vcs=git"

