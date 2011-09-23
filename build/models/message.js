(function() {
  var Message, Sanitizer;
  Sanitizer = require('sanitizer');
  Message = {
    through: function(socket) {
      this.socket = socket;
      return this;
    },
    user_connected: function(user_data) {
      return user_data;
    },
    user_disconnected: function(session) {
      return {
        id: this.socket.id,
        disconnected_at: new Date().getTime(),
        user: session.user
      };
    },
    list_of_users_updated: function(room) {
      return room.users;
    },
    new_user_data: function(data) {
      return {
        id: this.socket.id,
        connected_at: new Date().getTime(),
        user: data.user
      };
    },
    new_message: function(data, session) {
      return {
        id: this.socket.id,
        created_at: data.created_at,
        text: Sanitizer.escape(data.text),
        user: session.user
      };
    }
  };
  module.exports = Message;
}).call(this);
