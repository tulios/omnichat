(function() {
  var add_new_message, channel, client, connect, format_date, get_user, greetings_from_new_user, setup_chat_client;
  client = null;
  channel = null;
  setup_chat_client = function() {
    $("#message").focus();
    $('#message').keypress(function(e) {
      if (e.keyCode === 13) {
        e.preventDefault();
        return $("#send_button").click();
      }
    });
    return $("#send_button").click(function(e) {
      var message;
      e.preventDefault();
      message = $("#message").attr("value");
      client.send_message(message);
      $("#message").attr("value", "");
      return $("#message").focus();
    });
  };
  get_user = function() {
    return {
      id: "1234",
      nick: $("#user_nick").attr("value"),
      img: $("#user_img").attr("value")
    };
  };
  format_date = function(date) {
    var h, hour, m, minutes, s, seconds, _ref, _ref2, _ref3;
    h = date.getHours();
    hour = (_ref = h < 10) != null ? _ref : "0" + {
      h: h
    };
    m = date.getMinutes();
    minutes = (_ref2 = n < 10) != null ? _ref2 : "0" + {
      n: n
    };
    s = date.getSeconds();
    seconds = (_ref3 = s < 10) != null ? _ref3 : "0" + {
      s: s
    };
    return "" + hour + ":" + minutes + ":" + seconds;
  };
  greetings_from_new_user = function(user, text, class_name) {
    return add_new_message({
      user: user,
      text: text
    }, class_name);
  };
  add_new_message = function(data, class_name) {
    var message, message_container, message_img, message_nick, message_text, user;
    user = data.user;
    message = data.text;
    if (class_name == null) {
      class_name = "";
    }
    message_container = $('<div class="omnichat-message ' + class_name + '">');
    message_img = $('<div class="omnichat-user-img"><img src="' + user.img + '"></div>');
    message_nick = $('<div class="omnichat-user-nick">' + user.nick + '</div>');
    message_text = $('<div class="omnichat-user-text">' + message + '</div>');
    message_container.append(message_img);
    message_container.append(message_nick);
    message_container.append(message_text);
    $("#chat_messages_container").append(message_container);
    return $('body').get(0).scrollTop = 10000000;
  };
  connect = function() {
    channel = $("#user_channel").attr("value");
    client = new OmniChat.Client({
      host: "http://localhost:3000",
      user: get_user(),
      onConnect: function(data) {
        return console.log("Succesfuly connected! sessionId: " + client.sessionId);
      },
      onMyMessage: function(htmlSafeText) {
        console.log("On My Message");
        return add_new_message({
          user: client.user,
          text: htmlSafeText
        }, "omnichat-me");
      },
      onNewMessage: function(data) {
        console.log("On New Message");
        return add_new_message(data);
      },
      onSomeoneConnect: function(data) {
        console.log("" + data.user.nick + " connected!");
        return greetings_from_new_user(data.user, "" + data.user.nick + " connected!", "omnichat-connect");
      },
      onSomeoneDisconnect: function(data) {
        console.log("" + data.user.nick + " disconnected!");
        return greetings_from_new_user(data.user, "" + data.user.nick + " disconnected!", "omnichat-disconnect");
      }
    });
    return client.connect(channel, function() {
      $("#connect_form").hide();
      $("#chat_panel").show();
      return setup_chat_client();
    });
  };
  $(function() {
    return $("#connect_button").click(function(e) {
      e.preventDefault();
      return connect();
    });
  });
}).call(this);
