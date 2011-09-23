class Client
  ###
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
  ###
  constructor: (settings) ->
    @key = settings.key
    throw new Error("OmniChat::Client => Key is required for connection! Please, read the documentation") unless @key

    @channel = settings.channel

    if settings.host
      @host = "#{settings.host}?key=#{@key}"
    else
      @host = "http://omnichat.herokuapp.com?key=#{@key}"

    @user = settings.user
    @settings = settings

  ###
    Arguments:
      afterJoin: Function.
        This callback is called after joining into a channel

    e.g:
      client.connect(function(){
        // fake code...
        hideWaitRoom();
        showConnectedScreen();
      });
  ###
  connect: (afterJoin) ->
    @socket = io.connect(@host)

    this._listen_to('error', @settings.onError)
    @socket.on "connect", =>
      @socket.emit "join", {
        user: @user,
        channel: @channel
      }
      this._listen_events()
      afterJoin()

  ###
    Arguments:
      text: String.
        The text that will be sent.

    e.g:
      client.send_message("My message");
  ###
  send_message: (text) ->
    text = Util.html_safe(text)
    @socket.emit "message", {
      created_at: new Date().getTime(),
      text: text
    }
    @settings.onMyMessage(text) if @settings.onMyMessage

  _listen_events: ->
    this._listen_to 'succesfully connected', (data) =>
      @sessionId = data.id
      @settings.onConnect(data) if @settings.onConnect

    this._listen_to('new message', @settings.onNewMessage)
    this._listen_to('user connected', @settings.onSomeoneConnect)
    this._listen_to('user disconnected', @settings.onSomeoneDisconnect)
    this._listen_to('list of users updated', @settings.onListOfUsersUpdated)

  _listen_to: (event, callback) ->
    @socket.on event, (data) =>
      callback(this._format_message(data)) if callback

  _format_message: (data) ->
    data.text = Util.html_safe(data.text) if data.text
    data.created_at = new Date(data.created_at) if data.created_at
    data.disconnected_at = new Date(data.disconnected_at) if data.disconnected_at
    data.connected_at = new Date(data.connected_at) if data.connected_at
    data

window.OmniChat = {}
window.OmniChat.Client = Client