Channel = require("./channel")
Session = require("./session")

class SessionManager
  constructor: () ->
    @channel = new Channel();
    @sessions = {}
    # this._killOldSessionsListener()

  sessions: ->
    @sessions

  newSession: (nick) ->
    session = new Session @channel, nick
    console.log("creating session #{session.id}")
    @sessions[session.id] = session

  destroySession: (session) ->
    console.log("destroying session #{session.id}")
    session.destroy
    delete @sessions[session.id]

  _killOldSessionsListener: ->
    intervalCallback = ->
      now = new Date()
      for session in @sessions
        if now - session.timestamp > (timeout = 60*1000)
          this.destroySession(session)

    setInterval(intervalCallback, 1000)

module.exports = SessionManager