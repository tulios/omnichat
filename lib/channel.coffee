class Channel
  constructor: ->
    @messages = []
    @callbacks = []
    # this._clearOldCallbacks();

  addMessage: (nick, type, text) ->
    message = {
      nick: nick,
      type: type,
      text: text,
      timestamp: (new Date()).getTime()
    }

    this._routeMessage(message)
    @messages.push(message)
    while @callbacks.length > 0
      @callbacks.shift().callback(message)

    while @messages.length > (buffer = 20)
      @messages.shift()

  query: (since, callback) ->
    matching = []
    for message in @messages
      if message.timestamp > since then matching.push(message)

    if matching.length != 0
      callback(matching)
    else
     @callbacks.push({timestamp: new Date(), callback: callback})

  _routeMessage: (message) ->
    switch message.type
      when "msg"  then console.log("<#{message.nick}>: #{message.text}")
      when "join" then console.log("#{message.nick} joined")
      when "part" then console.log("#{message.nick} part")

  _clearOldCallbacks: ->
    intervalCallback = ->
      now = new Date();
      while @callbacks.length > 0 and now - @callbacks[0].timestamp > (thirtySeconds = 30*1000)
        @callbacks.shift().callback([])

    setInterval(intervalCallback, 3000)

module.exports = Channel