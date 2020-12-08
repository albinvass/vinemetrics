# Package

version                   = "0.1.0"
author                    = "Albin Vass"
description               = "Api for Vinescore"
license                   = "MIT"
srcDir                    = "src"
bin                       = @["vinescore_api"]
binDir                    = "bin"
namedBin["vinescore_api"] = "vinescore-api"


# Dependencies

requires "nim >= 1.4.2"
requires "rosencrantz"
