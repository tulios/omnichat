Channel = require("./channel")

class Session
  constructor: (channel, nick) ->
    @channel = channel
    @nick = nick
    @id = this._generateId()
    @timestamp = new Date()

  addMessage: (type, text) ->
    @channel.addMessage(@nick, type, text)

  ping: ->
    @timestamp = new Date()

  destroy: ->
    @channel.addMessage(@nick, "part")

  _generateId: ->
    Math.floor(Math.random()*99999999999).toString()

module.exports = Session