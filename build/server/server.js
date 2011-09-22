(function() {
  var Account, AuthenticationHandler, DATABASE_HOST, PORT, Room, Sanitizer, app, auth_handler, db, express, io, mongo;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  process.env.NODE_ENV = process.env.NODE_ENV || "development";
  PORT = process.env.PORT || 3000;
  DATABASE_HOST = process.env.MONGOLAB_URI || "mongodb://localhost:27017/omnichat";
  console.log("Environment: " + process.env.NODE_ENV);
  io = require('socket.io');
  express = require('express');
  mongo = require('mongoskin');
  Sanitizer = require('sanitizer');
  Room = require('./../models/room');
  Account = require('./../models/account');
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
      socket.set('session', data);
      socket.join(data.channel);
      user_data = {
        id: socket.id,
        connected_at: new Date().getTime(),
        user: data.user
      };
      socket.emit("succesfully connected", user_data);
      socket.broadcast.to(data.channel).emit("user connected", user_data);
      return Room["with"](db).find_or_create_and_add_user(data.channel, data.user, __bind(function(room) {
        socket.emit("list of users updated", room.users);
        return socket.broadcast.to(data.channel).emit("list of users updated", room.users);
      }, this));
    });
    /*
        message: (data)
      */
    socket.on('message', function(data) {
      return socket.get('session', function(err, session) {
        return socket.broadcast.to(session.channel).emit("new message", {
          id: socket.id,
          created_at: data.created_at,
          text: Sanitizer.escape(data.text),
          user: session.user
        });
      });
    });
    /*
        disconnect: (data)
      */
    return socket.on('disconnect', function() {
      return socket.get('session', function(err, session) {
        db.rooms.update({
          name: session.channel
        }, {
          '$pull': {
            users: session.user
          }
        });
        return socket.broadcast.to(session.channel).emit("user disconnected", {
          id: socket.id,
          disconnected_at: new Date().getTime(),
          user: session.user
        });
      });
    });
  });
}).call(this);
