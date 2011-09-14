sys = require("sys")
url = require("url");
qs = require("querystring")

BaseController = require("./base_controller")
SessionManager = require("./session_manager")

class Controller extends BaseController
  registerRoutes: ->
    self = this
    this.get "/who",
      (request, response) ->
        nicks = []
        for own id of self.sessionManager.sessions
          session = sessionManager.sessions[id]
          nicks.push(session.nick)

        response.simpleJSON(200, {nicks: nicks})

    this.get "/join",
      (request, response) ->
        nick = qs.parse(url.parse(request.url).query).nick
        if nick == null or nick.length == 0
          request.simpleJSON(400, {error: "Bad Nick!"})
          return

        session = self.sessionManager.newSession(nick)
        if session == null
          request.simpleJSON(400, {error: "Nick in use"})
          return

        response.simpleJSON(200, { id: session.id, nick: session.nick })

    this.get "/part",
      (request, response) ->
        id = qs.parse(url.parse(request.url).query).id
        if id and self.sessionManager.sessions[id]
          session = self.sessionManager.sessions[id]
          self.sessionManager.destroySession(session)

        response.simpleJSON(200, {status: "ok"})

    this.get "/send",
      (request, response) ->
        id = qs.parse(url.parse(request.url).query).id
        text = qs.parse(url.parse(request.url).query).text

        session = self.sessionManager.sessions[id]
        if !session or !text
          response.simpleJSON(400, {error: "No such session id!"})
          return

        session.ping()
        session.addMessage("msg", text)
        response.simpleJSON(200, {status: "ok"})

module.exports = Controller