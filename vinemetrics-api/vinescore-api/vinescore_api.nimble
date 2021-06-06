# Package

version                   = "0.1.0"
author                    = "Albin Vass"
description               = "Api for Vinescore"
license                   = "MIT"
srcDir                    = "src"
bin                       = @["vinemetrics_api"]
binDir                    = "bin"
namedBin["vinemetrics_api"] = "vinescore-api"


# Dependencies

requires "nim >= 1.4.2"
requires "rosencrantz"
