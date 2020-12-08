import os
import logging
import strformat
import asyncdispatch
import asynchttpserver
import httpclient
import rosencrantz


var logger = newConsoleLogger(levelThreshold=lvlDebug,
                              fmtStr="$datetime - $levelname - vinescore: ")


proc getChannelScore(channel: string): Handler =
  var location = getEnv("VINESCORE_GRAPHITE_HOST", "localhost")
  let port = getEnv("VINESCORE_GRAPHITE_PORT", "")
  if port != "":
    location &= ":" & port

  let client = newHttpClient()
  let req = &"http://{location}/render?target=stats.gauges.{channel}&format=json"
  try:
    complete(
      Http200,
      client.getContent(req),
      newHttpHeaders([("Content-Type", "application/json")])
    )
  except Exception:
    logger.log(lvlError, getCurrentExceptionMsg())
    raise


proc main() =
  let handler = rosencrantz.get[
    path("/api/status")[
      ok("OK")
    ] ~
    pathChunk("/api/score/")[
      pathEnd(getChannelScore)
    ]
  ]
  let server = newAsyncHttpServer()
  waitFor server.serve(Port(8080), handler)


when isMainModule:
  main()
