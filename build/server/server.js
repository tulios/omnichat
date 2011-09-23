(function() {
  var Account, AuthenticationHandler, DATABASE_HOST, Message, PORT, Room, app, auth_handler, db, express, io, mongo;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  process.env.NODE_ENV = process.env.NODE_ENV || "development";
  PORT = process.env.PORT || 3000;
  DATABASE_HOST = process.env.MONGOLAB_URI || "mongodb://localhost:27017/omnichat";
  console.log("Environment: " + process.env.NODE_ENV);
  io = require('socket.io');
  express = require('express');
  mongo = require('mongoskin');
  Room = require('./../models/room');
  Account = require('./../models/account');
  Message = require('./../models/message');
  AuthenticationHandler = require('./../authentication/handler');
  db = mongo.db(DATABASE_HOST);
  db.bind("rooms");
  db.bind("accounts");
  auth_handler = new AuthenticationHandler(db);
  app = express.createServer();
  app.listen(PORT, function() {
    var addr;
    addr = app.address();
    return console.log("OmniChat listening on http://" + addr.address + ":" + addr.port);
  });
  io = io.listen(app);
  io.configure('development', function() {
    io.set("transports", ['xhr-polling', 'jsonp-polling', 'htmlfile']);
    return io.set('authorization', __bind(function(handshakeData, callback) {
      return auth_handler.handle(handshakeData, callback);
    }, this));
  });
  io.configure('production', function() {
    io.set('log level', 1);
    io.set("transports", ['xhr-polling', 'jsonp-polling', 'htmlfile']);
    io.set("polling duration", 20);
    return io.set('authorization', __bind(function(handshakeData, callback) {
      return auth_handler.handle(handshakeData, callback);
    }, this));
  });
  app.configure(function() {
    return app.use(express.static(__dirname + '/../../public'));
  });
  io.sockets.on('connection', function(socket) {
    /*
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
      */    socket.on('join', function(data) {
      var account, user_data;
      account = socket.handshake.account;
      data.room_name = Room.get_room_name({
        channel: data.channel,
        key: account.key
      });
      socket.set('session', data);
      socket.join(data.room_name);
      user_data = Message.through(socket).new_user_data(data);
      socket.emit("succesfully connected", user_data);
      socket.broadcast.to(data.room_name).emit("user connected", Message.user_connected(user_data));
      return Room["with"](db).find_or_create_and_add_user(data.room_name, data.user, __bind(function(room) {
        var message;
        message = Message.list_of_users_updated(room);
        socket.emit("list of users updated", message);
        return socket.broadcast.to(data.room_name).emit("list of users updated", message);
      }, this));
    });
    /*
        message: (data)
      */
    socket.on('message', function(data) {
      return socket.get('session', function(err, session) {
        return socket.broadcast.to(session.room_name).emit("new message", Message.through(socket).new_message(data, session));
      });
    });
    /*
        disconnect: (data)
      */
    return socket.on('disconnect', function() {
      return socket.get('session', function(err, session) {
        Room["with"](db).remove_user({
          name: session.room_name
        }, session.user);
        return socket.broadcast.to(session.room_name).emit("user disconnected", Message.through(socket).user_disconnected(session));
      });
    });
  });
}).call(this);
