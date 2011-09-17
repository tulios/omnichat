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
    socket.set 'session', data
    socket.join(data.channel)
    user_data = {
      id: socket.id,
      connected_at: new Date().getTime(),
      user: data.user
    }

    socket.emit "succesfully connected", user_data
    socket.broadcast.to(data.channel).emit("user connected", user_data)

  socket.on 'message', (data) ->
    socket.get 'session', (err, session) ->
      socket.broadcast.to(session.channel).emit("new message", {
        id: socket.id,
        created_at: data.created_at,
        text: data.text,
        user: session.user
      })

  socket.on 'disconnect', ->
    socket.get 'session', (err, session) ->
      socket.broadcast.to(session.channel).emit("user disconnected", {
        id: socket.id,
        disconnected_at: new Date().getTime(),
        user: session.user
      })