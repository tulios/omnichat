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
  socket.emit 'news', { hello: "Enviado pelo server: world" }
  socket.on 'my other event', (data) ->
    console.log("recebido pelo client: #{data.my}")