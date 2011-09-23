Sanitizer = require 'sanitizer'

Message = {

  through: (socket) ->
    @socket = socket
    this

  user_connected: (user_data) ->
    user_data

  user_disconnected: (session) ->
    {
      id: @socket.id,
      disconnected_at: new Date().getTime(),
      user: session.user
    }

  list_of_users_updated: (room) ->
    room.users

  new_user_data: (data) ->
    {
      id: @socket.id,
      connected_at: new Date().getTime(),
      user: data.user
    }

  new_message: (data, session) ->
    {
      id: @socket.id,
      created_at: data.created_at,
      text: Sanitizer.escape(data.text),
      user: session.user
    }

}

module.exports = Message