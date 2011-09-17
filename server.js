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
    io.enable('browser client minification');
    io.enable('browser client etag');
    io.set('log level', 1);
    return io.set('transports', ['websocket', 'flashsocket', 'htmlfile', 'xhr-polling', 'jsonp-polling']);
  });
  app.configure(function() {
    return app.use(express.static(__dirname + '/public'));
  });
  io.sockets.on('connection', function(socket) {
    socket.on('join', function(data) {
      var channel;
      socket.set('user', data);
      channel = data.channel;
      socket.join(channel);
      return console.log("" + data.nick + " join to " + channel);
    });
    return socket.on('message', function(data) {
      return socket.get('user', function(err, user) {
        console.log("broadcast to " + user.channel);
        return socket.broadcast.to(user.channel).emit("new message", {
          id: socket.id,
          nick: user.nick,
          img: user.img,
          text: data.text
        });
      });
    });
  });
}).call(this);
