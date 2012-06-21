HashLib = require 'jshashes/server/lib/hashes'

Account = {

  with: (db) ->
    @db = db
    this

  create: (email, hosts) ->
    created_at = new Date().getTime()
    key = this.generate_key("#{email}|#{created_at}")
    @db.accounts.save {key: key, email: email, hosts: hosts, created_at: created_at}

  generate_key: (string) ->
    new Hashes.SHA1(string).toUpperCase()

  find: (query, callback) ->
    @db.accounts.find(query).toArray (err, accounts) =>
      callback(accounts)

  check_by_key_and_connect_host: (key, connected_host, callbacks) ->
    this.find {key: key, hosts: connected_host}, (accounts) =>
      if accounts.length == 1
        callbacks.on_accepted(accounts[0])
      else
        callbacks.on_rejected()

}

module.exports = Account