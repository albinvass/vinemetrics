# Package

version                   = "0.1.0"
author                    = "Albin Vass"
description               = "irc bot for Vinescore"
license                   = "MIT"
srcDir                    = "src"
bin                       = @["vinescore-irc"]
binDir                    = "bin"
namedBin["vinescore_irc"] = "vinescore-irc"


# Dependencies

requires "nim >= 1.4.2"
requires "irc"
requires "metrics"

before test:
  exec "nimble install -d --accept"

task test, "Run Testament":
  exec "testament cat ."
