PORT = process.env.PORT || 3000
HOST = process.env.HOST || null

io = require 'socket.io'
express = require 'express'

app = express.createServer()
app.listen(PORT)
io = io.listen(app)

io.configure 'development', ->
  io.set 'transports', ['websocket']

io.configure 'production', ->
  io.enable 'browser client minification'
  io.enable 'browser client etag'
  io.set 'log level', 1
  io.set 'transports', ['websocket', 'flashsocket', 'htmlfile', 'xhr-polling', 'jsonp-polling']

app.configure ->
  app.use(express.static(__dirname + '/public'))

io.sockets.on 'connection', (socket) ->
  socket.on 'join', (data) ->
    socket.set 'user', data
    channel = data.channel
    socket.join(channel)
    console.log("#{data.nick} join to #{channel}")

  socket.on 'message', (data) ->
    socket.get 'user', (err, user) ->
      console.log("broadcast to #{user.channel}")
      socket.broadcast.to(user.channel).emit("new message", {
        id: socket.id,
        nick: user.nick,
        img: user.img
        text: data.text
      })