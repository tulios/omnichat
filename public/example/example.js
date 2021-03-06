(function() {
  var add_new_message, channel, client, connect, format_date, get_user, greetings_from_new_user, refresh_users_list, remove_from_the_users_list, setup_chat_client;
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
    $('.omnichat-message:last').removeClass('ultima_mensagem');
    user = data.user;
    message = data.text;
    if (class_name == null) {
      class_name = "";
    }
    message_container = $('<div class="omnichat-message ' + class_name + '"></div>');
    message_img = $('<div class="omnichat-user-img"><img src="' + user.img + '"></div>');
    message_nick = $('<div class="omnichat-user-nick">' + user.nick + '</div>');
    message_text = $('<div class="omnichat-user-text">' + message + '<div class="rabo-balao"></div></div>');
    message_container.append(message_img);
    message_container.append(message_nick);
    message_container.append(message_text);
    message_container.fadeIn('fast');
    $("#chat_messages_container").append(message_container);
    $('.omnichat-message:last').addClass('ultima_mensagem');
    return $('#chat_messages_container').get(0).scrollTop = 100000000000;
  };
  remove_from_the_users_list = function(user) {
    return $("#chat_users_container #user_" + user.nick).remove();
  };
  refresh_users_list = function(users_list) {
    var user, user_div, user_img, user_name, users_container, _i, _len;
    users_container = $("#chat_users_container");
    for (_i = 0, _len = users_list.length; _i < _len; _i++) {
      user = users_list[_i];
      if ($("#chat_users_container #user_" + user.nick).length === 0) {
        user_div = $('<div id="user_' + user.nick + '" class="omnichat-user"></div>');
        user_img = $('<div class="omnichat-user-img"><img src="' + user.img + '"></div>');
        user_name = $('<div class="omnichat-user-name">' + user.nick + '</div>');
        user_div.append(user_img);
        user_div.append(user_name);
        users_container.append(user_div);
      }
    }
    return users_container.show();
  };
  connect = function() {
    client = new OmniChat.Client({
      host: "http://omnichat.herokuapp.com",
      key: "C3747C316C161E4C11A18CD1F8C2456F85EFBC9D",
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
        return add_new_message(data, "omnichat-you");
      },
      onSomeoneConnect: function(data) {
        console.log("" + data.user.nick + " connected!");
        return greetings_from_new_user(data.user, "" + data.user.nick + " connected!", "omnichat-connect");
      },
      onSomeoneDisconnect: function(data) {
        console.log("" + data.user.nick + " disconnected!");
        greetings_from_new_user(data.user, "" + data.user.nick + " disconnected!", "omnichat-disconnect");
        return remove_from_the_users_list(data.user);
      },
      onListOfUsersUpdated: function(data) {
        console.log("list of users updated");
        return refresh_users_list(data);
      },
      onError: function(reason) {
        return console.log("Falha ao se conectar: " + reason);
      }
    });
    return client.connect(function() {
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
