PORT = process.env.PORT || 3000
HOST = process.env.HOST || null
ENV = process.env.NODE_ENV || "development"

console.log("Environment: #{ENV}")

io = require 'socket.io'
express = require 'express'

app = express.createServer()

app.listen PORT, ->
  addr = app.address()
  console.log("OmniChat listening on http://#{addr.address}:#{addr.port}")

io = io.listen(app)

io.configure 'development', ->
  io.set 'transports', ['websocket']

io.configure 'production', ->
  io.set 'log level', 1
  # 'websocket' => nao suportado pelo heroku
  # 'flashsocket' => nao suportado pelo heroku
  io.set "transports", ['xhr-polling', 'jsonp-polling', 'htmlfile']
  io.set "polling duration", 10

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