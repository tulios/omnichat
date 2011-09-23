(function() {
  var Room;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Room = {
    "with": function(db) {
      this.db = db;
      return this;
    },
    "new": function(name, users) {
      return {
        name: name,
        users: users
      };
    },
    find: function(query, callback) {
      return this.db.rooms.find(query).toArray(__bind(function(err, rooms) {
        return callback(rooms);
      }, this));
    },
    save: function(data) {
      return this.db.rooms.save(data);
    },
    add_user: function(query, user) {
      return this.db.rooms.update(query, {
        '$push': {
          users: user
        }
      });
    },
    remove_user: function(query, user) {
      return this.db.rooms.update(query, {
        '$pull': {
          users: user
        }
      });
    },
    find_or_create_and_add_user: function(channel, user, callback) {
      return this.find({
        name: channel
      }, __bind(function(rooms) {
        var room;
        room = this["new"](channel, [user]);
        if (rooms.length === 0) {
          this.save(room);
        } else {
          this.add_user({
            name: channel
          }, user);
          room = rooms[0];
          room.users = room.users.concat(user);
        }
        return callback(room);
      }, this));
    },
    get_room_name: function(json) {
      return "" + json.key + "-" + json.channel;
    }
  };
  module.exports = Room;
}).call(this);
