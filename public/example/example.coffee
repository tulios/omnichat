client = null
channel = null

setup_chat_client = ->
  $("#message").focus()
  $('#message').keypress (e) ->
    if e.keyCode == 13
      e.preventDefault()
      $("#send_button").click()

  $("#send_button").click (e) ->
    e.preventDefault()
    message = $("#message").attr "value"
    client.send_message message
    $("#message").attr "value", ""
    $("#message").focus()

get_user = ->
  {
    id: "1234",
    nick: $("#user_nick").attr("value"),
    img: $("#user_img").attr("value")
  }

format_date = (date) ->
  h = date.getHours()
  hour = h < 10 ? "0" + h : h;
  m = date.getMinutes();
  minutes = n < 10 ? "0" + n : n;
  s = date.getSeconds();
  seconds = s < 10 ? "0" + s : s;
  "#{hour}:#{minutes}:#{seconds}"

greetings_from_new_user = (user, text, class_name) ->
  add_new_message({user: user, text: text}, class_name)

add_new_message = (data, class_name) ->
  user = data.user
  message = data.text
  class_name ?= ""
  message_container = $('<div class="omnichat-message '+class_name+'">')
  message_img = $('<div class="omnichat-user-img"><img src="'+user.img+'"></div>')
  message_nick = $('<div class="omnichat-user-nick">' +user.nick+'</div>')
  message_text = $('<div class="omnichat-user-text">' +message+'</div>')

  message_container.append(message_img)
  message_container.append(message_nick)
  message_container.append(message_text)
  $("#chat_messages_container").append(message_container)
  $('body').get(0).scrollTop = 10000000

connect = ->
  channel = $("#user_channel").attr "value"
  client = new OmniChat.Client({
    host: "http://localhost:3000",
    user: get_user(),
    onConnect: (data) ->
      console.log("Succesfuly connected! sessionId: #{client.sessionId}")

    onMyMessage: (htmlSafeText) ->
      console.log("On My Message")
      add_new_message({user: client.user, text: htmlSafeText}, "omnichat-me")

    onNewMessage: (data) ->
      console.log("On New Message")
      add_new_message(data)

    onSomeoneConnect: (data) ->
      console.log("#{data.user.nick} connected!")
      greetings_from_new_user(data.user, "#{data.user.nick} connected!", "omnichat-connect")

    onSomeoneDisconnect: (data) ->
      console.log("#{data.user.nick} disconnected!")
      greetings_from_new_user(data.user, "#{data.user.nick} disconnected!", "omnichat-disconnect")
  })

  client.connect channel, ->
    $("#connect_form").hide();
    $("#chat_panel").show();
    setup_chat_client()

$ ->
  $("#connect_button").click (e) ->
    e.preventDefault()
    connect()