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
  message_container = $('<div class="omnichat-message '+class_name+'"></div>')
  message_img = $('<div class="omnichat-user-img"><img src="'+user.img+'"></div>')
  message_nick = $('<div class="omnichat-user-nick">' +user.nick+'</div>')
  message_text = $('<div class="omnichat-user-text">' +message+'</div>')

  message_container.append(message_img)
  message_container.append(message_nick)
  message_container.append(message_text)
  $("#chat_messages_container").append(message_container)
  $('body').get(0).scrollTop = 10000000

remove_from_the_users_list = (user) ->
  $("#chat_users_container #user_#{user.nick}").remove()

refresh_users_list = (users_list) ->
  users_container = $("#chat_users_container")
  for user in users_list
    if $("#chat_users_container #user_" + user.nick).length == 0
      user_div = $('<div id="user_'+user.nick+'" class="omnichat-user"></div>')
      user_img = $('<div class="omnichat-user-img"><img src="'+user.img+'"></div>')
      user_name = $('<div class="omnichat-user-name">' +user.nick+'</div>')
      user_div.append(user_img)
      user_div.append(user_name)
      users_container.append(user_div)

  users_container.show()

connect = ->
  client = new OmniChat.Client({
    host: "http://localhost:3000",
    key: "C3747C316C161E4C11A18CD1F8C2456F85EFBC9D",
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
      remove_from_the_users_list(data.user)

    onListOfUsersUpdated: (data) ->
      console.log("list of users updated")
      refresh_users_list(data)

    onError: (reason) ->
      console.log("Falha ao se conectar: #{reason}")
  })

  client.connect ->
    $("#connect_form").hide();
    $("#chat_panel").show();
    setup_chat_client()

$ ->
  $("#connect_button").click (e) ->
    e.preventDefault()
    connect()