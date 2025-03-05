version     = "0.0.1"
author      = "carrexxii"
description = "Nim maths library designed for games and graphics"
license     = "AGPLv3"

#[ -------------------------------------------------------------------- ]#

import std/strformat

task build_docs, "Build the project's docs":
    exec "nim md2html --index:only --outdir:docs docs/*.md"
    exec "nim md2html --outdir:docs docs/*.md"

    let git_hash = (gorge_ex "git rev-parse HEAD").output
    exec &"nim doc --project --index:on --git.url:https://github.com/carrexxii/ngm --git.commit:{git_hash} --outdir:docs ngm.nim"
    exec "cp docs/theindex.html docs/index.html"

task update_docs, "Update the docs branch":
    try:
        exec "git stash"
        exec "git checkout docs"
        exec "git add docs/**"
        exec "git commit -m \".\""
    except OsError:
        discard
    finally:
        exec "git checkout master"
        exec "git stash pop"
