process.env.NODE_ENV = process.env.NODE_ENV || "development"
PORT = process.env.PORT || 3000
DATABASE_HOST = process.env.MONGOLAB_URI || "mongodb://localhost:27017/omnichat"

console.log("Environment: #{process.env.NODE_ENV}")

io = require 'socket.io'
express = require 'express'
mongo = require 'mongoskin'
Room = require './../models/room'
Account = require './../models/account'
Message = require './../models/message'
AuthenticationHandler = require './../authentication/handler'

db = mongo.db(DATABASE_HOST)
db.bind("rooms")
db.bind("accounts")
auth_handler = new AuthenticationHandler(db)

app = express.createServer()

app.listen PORT, ->
  addr = app.address()
  console.log("OmniChat listening on http://#{addr.address}:#{addr.port}")

io = io.listen(app)

io.configure 'development', ->
  io.set "transports", ['xhr-polling', 'jsonp-polling', 'htmlfile']
  io.set 'authorization', (handshakeData, callback) =>
    auth_handler.handle(handshakeData, callback)

io.configure 'production', ->
  io.set 'log level', 1
  # 'websocket' => nao suportado pelo heroku
  # 'flashsocket' => nao suportado pelo heroku
  io.set "transports", ['xhr-polling', 'jsonp-polling', 'htmlfile']
  io.set "polling duration", 20
  io.set 'authorization', (handshakeData, callback) =>
    auth_handler.handle(handshakeData, callback)

app.configure ->
  app.use(express.static(__dirname + '/../../public'))

io.sockets.on 'connection', (socket) ->
  ###
    join: (data)
      It will be called when a new user try to join into a room. This socket will notify the user who
      tries to connect with "succesfully connected" and will inform the connection timestamp, the id
      of the session and give it back its JSON. It also will broadcast an "user connected" message to
      notify everybody in the room. Finaly it will broadcast "list of users updated" and send the
      same message for the author of the connection.

      data:
        {
          channel: String,
          user: JSON <This JSON is defined by the client>
        }
  ###
  socket.on 'join', (data) ->
    account = socket.handshake.account

    channel = account.connected_path
    channel = data.channel if data.channel
    data.channel = channel

    data.room_name = Room.get_room_name({channel: data.channel, key: account.key})

    socket.set 'session', data
    socket.join(data.room_name)

    user_data = Message.through(socket).new_user_data(data)

    socket.emit "succesfully connected", user_data
    socket.broadcast.to(data.room_name).emit("user connected", Message.user_connected(user_data))

    Room.with(db).find_or_create_and_add_user data.room_name, data.user, (room) =>
      message = Message.list_of_users_updated(room)
      socket.emit "list of users updated", message
      socket.broadcast.to(data.room_name).emit("list of users updated", message)

  ###
    message: (data)
  ###
  socket.on 'message', (data) ->
    socket.get 'session', (err, session) ->
      socket.broadcast.to(session.room_name).emit("new message", Message.through(socket).new_message(data, session))

  ###
    disconnect: (data)
  ###
  socket.on 'disconnect', ->
    socket.get 'session', (err, session) ->
      Room.with(db).remove_user {name: session.room_name}, session.user
      socket.broadcast.to(session.room_name).emit("user disconnected", Message.through(socket).user_disconnected(session))


























