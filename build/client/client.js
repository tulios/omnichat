(function() {
  var Client;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Client = (function() {
    /*
        Arguments:
          JSON:
            host: String
              If host is set to omnichat will use it instead of the true host.
            key: String
              The key received from the server. Required.
            channel: String
              The name of the channel. This is the name that will agregate all the users. Leave it blank
              if you want the pages to serve as aggregator address.
            user: JSON
              Your definition of an user, it will be passed for everyone who need to receive a message
              from this user.
            onConnect: Function(data)
              This callback is called after the user connection is succesfuly established on the server.
              It will receive a JSON object that contains your user JSON and a connected_at date, like:
              {
                id: "sessionId",
                connected_at: Date,
                user:{<your JSON data>}
              }
            onMyMessage: Function(messageHtmlSafe)
              This callback is called after your message have been sent to the channel. It will receive
              a html safe version of the passed message.
            onNewMessage: Function(data)
              This callback is called when a new message arives to the connected channel. It will receive
              a JSON object that contains your user JSON and a text attribute, like:
              {
                id: "sessionId",
                created_at: Date,
                text: "msg",
                user:{<your JSON data>}
              }
            onSomeoneConnect: Function(data)
              This callback is called when a user connects to the server. It will receive a JSON object that
              contains your user JSON and a connected_at date. Same data as "onConnect".
            onSomeoneDisconnect: Function(data)
              This callback is called when a user disconnects from the server. It will receive a JSON object
              that contains your user JSON and a disconnected_at date, like:
              {
                id: "sessionId",
                disconnected_at: Date,
                user:{<your JSON data>}
              }
            onError: Function(reason)
              This callback is called, usually, when a authorization error occurs.
    
        TIP: The client will have a sessionId attribute after succesfuly connects to the server, so, after
             onConnect it is possible to knows the sessionId. e.g: client.sessionId.
    
        e.g:
          var client = new OmniChat.Client({
            key: "MyKey...",
            user: {
              // example data, use what your want
              id: '123',
              nick: 'myNick',
              img: 'http://.../someImage.jpg'
            },
            onConnect: function(data) {
              // fake code...
              turnOnGreenLight();
            },
            onMyMessage: function(messageHtmlSafe) {
              // fake code...
              addMyMessage(messageHtmlSafe);
            },
            onNewMessage: function(data) {
              // fake code...
              var user = data.user;
              var message = data.text;
              addNewMessage(user, message);
            },
            onSomeoneConnect: function(data) {
              // fake code...
              var user = data.user;
              notifyUserList(user, data.connected_at);
            },
            onSomeoneDisconnect: function(data) {
              // fake code...
              var user = data.user;
              notifyUserList(user, data.disconnected_at);
            },
            onError: function(reason) {
              // fake code...
              console.log(reason)
            }
          });
      */    function Client(settings) {
      this.key = settings.key;
      if (!this.key) {
        throw new Error("OmniChat::Client => Key is required for connection! Please, read the documentation");
      }
      this.channel = settings.channel;
      if (settings.host) {
        this.host = "" + settings.host + "?key=" + this.key;
      } else {
        this.host = "http://omnichat.herokuapp.com?key=" + this.key;
      }
      this.user = settings.user;
      this.settings = settings;
    }
    Client.prototype.connect = function(beforeConnect) {
      this.socket = io.connect(this.host);
      this._listen_to('error', this.settings.onError);
      return this.socket.on("connect", __bind(function() {
        this.socket.emit("join", {
          user: this.user,
          channel: this.channel
        });
        this._listen_events();
        return beforeConnect();
      }, this));
    };
    Client.prototype.send_message = function(text) {
      text = Util.html_safe(text);
      this.socket.emit("message", {
        created_at: new Date().getTime(),
        text: text
      });
      if (this.settings.onMyMessage) {
        return this.settings.onMyMessage(text);
      }
    };
    Client.prototype._listen_events = function() {
      this._listen_to('succesfully connected', __bind(function(data) {
        this.sessionId = data.id;
        if (this.settings.onConnect) {
          return this.settings.onConnect(data);
        }
      }, this));
      this._listen_to('new message', this.settings.onNewMessage);
      this._listen_to('user connected', this.settings.onSomeoneConnect);
      this._listen_to('user disconnected', this.settings.onSomeoneDisconnect);
      return this._listen_to('list of users updated', this.settings.onListOfUsersUpdated);
    };
    Client.prototype._listen_to = function(event, callback) {
      return this.socket.on(event, __bind(function(data) {
        if (callback) {
          return callback(this._format_message(data));
        }
      }, this));
    };
    Client.prototype._format_message = function(data) {
      if (data.text) {
        data.text = Util.html_safe(data.text);
      }
      if (data.created_at) {
        data.created_at = new Date(data.created_at);
      }
      if (data.disconnected_at) {
        data.disconnected_at = new Date(data.disconnected_at);
      }
      if (data.connected_at) {
        data.connected_at = new Date(data.connected_at);
      }
      return data;
    };
    return Client;
  })();
  window.OmniChat = {};
  window.OmniChat.Client = Client;
}).call(this);
