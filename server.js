(function() {
  var HOST, PORT, app, express, io;
  PORT = process.env.PORT || 3000;
  HOST = process.env.HOST || null;
  io = require('socket.io');
  express = require('express');
  app = express.createServer();
  app.listen(PORT);
  io = io.listen(app);
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
