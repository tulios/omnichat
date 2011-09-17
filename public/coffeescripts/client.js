(function() {
  var Client;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Client = (function() {
    function Client(settings) {
      this.id = settings.user.id;
      this.nick = settings.user.nick;
      this.img = settings.user.img;
      this.onMessageCallback = settings.onMessage;
    }
    Client.prototype.connect = function(channel, onConnect) {
      this.channel = channel;
      this.socket = io.connect('http://omnichat.herokuapp.com');
      console.log("" + this.nick + " join channel " + this.channel);
      return this.socket.on("connect", __bind(function() {
        this.socket.emit("join", {
          id: this.id,
          nick: this.nick,
          img: this.img,
          channel: this.channel
        });
        this._listen_new_messages();
        return onConnect();
      }, this));
    };
    Client.prototype.send_message = function(text) {
      console.log("Sending message...");
      return this.socket.emit("message", {
        created_at: new Date().getTime(),
        text: text
      });
    };
    Client.prototype._listen_new_messages = function() {
      console.log("Start to listening new messages...");
      return this.socket.on('new message', __bind(function(data) {
        console.log("Receiving message...");
        return this.onMessageCallback(data);
      }, this));
    };
    return Client;
  })();
  window.Client = Client;
}).call(this);
