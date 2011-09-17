ENV = process.env.NODE_ENV || "development"
PORT = process.env.PORT || 3000
DATABASE_HOST = process.env.MONGOHQ_URL || "mongodb://localhost:27017/omnichat"

console.log("Environment: #{ENV}")

io = require 'socket.io'
express = require 'express'
mongo = require 'mongoskin'

db = mongo.db(DATABASE_HOST)
db.bind("rooms")

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
    socket.set 'session', data
    channel = data.channel
    socket.join(channel)

    user_data = {
      id: socket.id,
      connected_at: new Date().getTime(),
      user: data.user
    }

    socket.emit "succesfully connected", user_data
    socket.broadcast.to(channel).emit("user connected", user_data)

    db.rooms.find({name: channel}).toArray (err, rooms) =>
      users = [data.user]
      if rooms.length == 0
        db.rooms.save {name: channel, users: users}
      else
        users = users.concat rooms[0].users
        db.rooms.update {name: channel}, {'$push': {users: data.user}}

      socket.emit "list of users updated", users
      socket.broadcast.to(channel).emit("list of users updated", users)

  ###
    message: (data)
  ###
  socket.on 'message', (data) ->
    socket.get 'session', (err, session) ->
      socket.broadcast.to(session.channel).emit("new message", {
        id: socket.id,
        created_at: data.created_at,
        text: data.text,
        user: session.user
      })

  ###
    disconnect: (data)
  ###
  socket.on 'disconnect', ->
    socket.get 'session', (err, session) ->
      db.rooms.update {name: session.channel}, {'$pull': {users: session.user}}
      socket.broadcast.to(session.channel).emit("user disconnected", {
        id: socket.id,
        disconnected_at: new Date().getTime(),
        user: session.user
      })