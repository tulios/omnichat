Room = {
  with: (db) ->
    @db = db
    this

  new: (name, users) ->
    {name: name, users: users}

  find: (query, callback) ->
    @db.rooms.find(query).toArray (err, rooms) =>
      callback(rooms)

  save: (data) ->
    @db.rooms.save(data)

  add_user: (query, user) ->
    @db.rooms.update query, {'$push': {users: user}}

  remove_user: (query, user) ->
    @db.rooms.update query, {'$pull': {users: user}}

  find_or_create_and_add_user: (channel, user, callback) ->
    this.find {name: channel}, (rooms) =>
      room = this.new(channel, [user])
      if rooms.length == 0
        this.save(room)
      else
        this.add_user {name: channel}, user
        room = rooms[0]
        room.users = room.users.concat(user)

      callback(room)

   get_room_name: (json) ->
     "#{json.key}-#{json.channel}"
}

module.exports = Room