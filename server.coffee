PORT = process.env.PORT || 3000
HOST = process.env.HOST || null

io = require 'socket.io'
express = require 'express'

app = express.createServer()
app.listen(PORT)
io = io.listen(app)

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