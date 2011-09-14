PORT = process.env.PORT || 3000
HOST = process.env.HOST || null

qs = require("querystring")
url = require("url")
sys = require("sys")

Channel = require("./lib/channel")
SessionManager = require("./lib/session_manager")
Controller = require("./lib/controller")

sessions = {}
channel = new Channel
sessionManager = new SessionManager(channel)

controller = new Controller
controller.listen(PORT, HOST)

controller.get "/who",
  (request, response) ->
    nicks = []
    for own id of sessionManager.sessions
      session = sessionManager.sessions[id]
      nicks.push(session.nick)

    response.simpleJSON(200, {nicks: nicks})

controller.get "/join",
  (request, response) ->
    nick = qs.parse(url.parse(request.url).query).nick
    if nick == null or nick.length == 0
      request.simpleJSON(400, {error: "Bad Nick!"})
      return

    session = sessionManager.newSession(nick)
    if session == null
      request.simpleJSON(400, {error: "Nick in use"})
      return

    response.simpleJSON(200, { id: session.id, nick: session.nick })

controller.get "/part",
  (request, response) ->
    id = qs.parse(url.parse(request.url).query).id
    if id and sessionManager.sessions[id]
      session = sessionManager.sessions[id]
      sessionManager.destroySession(session)

    response.simpleJSON(200, {status: "ok"})

controller.get "/send",
  (request, response) ->
    id = qs.parse(url.parse(request.url).query).id
    text = qs.parse(url.parse(request.url).query).text

    session = sessionManager.sessions[id]
    if !session or !text
      response.simpleJSON(400, {error: "No such session id!"})
      return

    session.ping()
    session.addMessage("msg", text)
    response.simpleJSON(200, {status: "ok"})



















