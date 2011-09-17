class Client
  constructor: (settings) ->
    @id = settings.user.id
    @nick = settings.user.nick
    @img = settings.user.img
    @onMessageCallback = settings.onMessage

  connect: (channel, onConnect) ->
    @channel = channel
    @socket = io.connect('http://omnichat.herokuapp.com')
    console.log("#{@nick} join channel #{@channel}")
    @socket.on "connect", =>
      @socket.emit "join", {
        id: @id,
        nick: @nick,
        img: @img,
        channel: @channel
      }
      this._listen_new_messages();
      onConnect()

  send_message: (text) ->
    console.log("Sending message...")
    @socket.emit "message", {
      created_at: new Date().getTime(),
      text: text
    }

  _listen_new_messages: ->
    console.log("Start to listening new messages...")
    @socket.on 'new message', (data) =>
      console.log("Receiving message...")
      @onMessageCallback(data)

window.Client = Client