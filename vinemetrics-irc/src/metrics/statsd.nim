when defined(metrics):
  proc statsdBackend(address: string, port: Port = 8125)
