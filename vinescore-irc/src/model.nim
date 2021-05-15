import tables
import logging
import metrics
import strutils
import strformat
import yaml/serialization, yaml/annotations, streams

from os import fileExists

type
  VineScoreConfig = ref VineScoreConfigObj
  VineScoreConfigObj = object
    channels*: TableRef[string, Channel]

  Channel* = ref object
    currentScore* {.transient.}: int64
    gauge* {.transient.}: Gauge
    maxVote* {.defaultVal: 5.}: int
    minVote* {.defaultVal: -5.}: int
    emotes* {.sparse.}: Option[TableRef[string, ChannelEmote]]

  ChannelEmote* = ref object
    gauge* {.transient.}: Gauge

proc addMetrics(config: var VineScoreConfig, logger: var ConsoleLogger) =
  when defined(metrics):
    for channelName, channel in config.channels:
      let channelScoreGaugeName = &"{channelName[1..^1]}:score"
      channel.gauge = newGauge(channelScoreGaugeName, &"{channelName} gauge")
      logger.log(
        lvlInfo,
        &"Configured channel gauge {channelName}"
      )
      try:
        logger.log(
          lvlInfo,
          &"Configuring emote gauges channel {channelName}"
        )
        for emoteName, emote in channel.emotes.get():
          let emoteGaugeName = &"{channelName[1..^1]}:emotes:{emoteName}"
          logger.log(
            lvlDebug,
            &"Configuring emote gauge {emoteGaugeName}" &
            &"for channel {channelName}"
          )
          emote.gauge = newGauge(&"{emoteGaugeName}", &"{emoteName} gauge")
      except UnpackDefect:
        logger.log(
          lvlDebug,
          &"No emotes configured for channel {channelName}"
        )
    
proc init*(path: string = "/etc/vinescore/config.yaml"): VineScoreConfig =
  var logger = newConsoleLogger(levelThreshold=lvlDebug,
                                fmtStr="$datetime - $levelname - vinescore.model: ")
  var config: VineScoreConfig
  if fileExists(path):
    var s = newFileStream(path)
    serialization.load(s, config)
    s.close()
    addMetrics(config, logger)
  else:
    config = VineScoreConfig(
      channels: newTable[string, Channel]()
    )
  config
