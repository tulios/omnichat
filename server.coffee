PORT = process.env.PORT || 3000
HOST = process.env.HOST || null

Channel = require("./lib/channel")
SessionManager = require("./lib/session_manager")
HttpServer = require("./lib/http_server")
Controller = require("./lib/controller")

console.log("Starting server...\n")
sessions = {}
channel = new Channel
sessionManager = new SessionManager(channel)
httpServer = new HttpServer()

controller = new Controller(sessionManager)
controller.registerRoutes()

httpServer.mergeRoutes(controller)
httpServer.listen(PORT, HOST)
process.addListener "SIGINT", ->
  httpServer.close()
  process.exit(0)