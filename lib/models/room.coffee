Room = {
  new: (name, users) ->
    {name: name, users: users}

  with: (db) ->
    @db = db
    this

  find: (query, callback) ->
    @db.rooms.find(query).toArray (err, rooms) =>
      callback(rooms)

  save: (data) ->
    @db.rooms.save(data)

  add_user: (query, user) ->
    @db.rooms.update query, {'$push': {users: user}}

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
}

module.exports = Room