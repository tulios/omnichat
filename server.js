(function() {
  var ENV, HOST, PORT, app, express, io;
  PORT = process.env.PORT || 3000;
  HOST = process.env.HOST || null;
  ENV = process.env.NODE_ENV || "development";
  console.log("Environment: " + ENV);
  io = require('socket.io');
  express = require('express');
  app = express.createServer();
  app.listen(PORT, function() {
    var addr;
    addr = app.address();
    return console.log("OmniChat listening on http://" + addr.address + ":" + addr.port);
  });
  io = io.listen(app);
  io.configure('development', function() {
    return io.set('transports', ['websocket']);
  });
  io.configure('production', function() {
    io.set('log level', 1);
    io.set("transports", ['xhr-polling', 'jsonp-polling', 'htmlfile']);
    return io.set("polling duration", 10);
  });
  app.configure(function() {
    return app.use(express.static(__dirname + '/public'));
  });
  io.sockets.on('connection', function(socket) {
    socket.on('join', function(data) {
      var user_data;
      socket.set('session', data);
      socket.join(data.channel);
      user_data = {
        id: socket.id,
        connected_at: new Date().getTime(),
        user: data.user
      };
      socket.emit("succesfully connected", user_data);
      return socket.broadcast.to(data.channel).emit("user connected", user_data);
    });
    socket.on('message', function(data) {
      return socket.get('session', function(err, session) {
        return socket.broadcast.to(session.channel).emit("new message", {
          id: socket.id,
          created_at: data.created_at,
          text: data.text,
          user: session.user
        });
      });
    });
    return socket.on('disconnect', function() {
      return socket.get('session', function(err, session) {
        return socket.broadcast.to(session.channel).emit("user disconnected", {
          id: socket.id,
          disconnected_at: new Date().getTime(),
          user: session.user
        });
      });
    });
  });
}).call(this);
