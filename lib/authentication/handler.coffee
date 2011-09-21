Account = require './../models/account'

class AuthenticationHandler
  constructor: (db) ->
    @db = db
    @hostExtractor = new RegExp("http://[^/]+")

  handle: (handshakeData, callback) ->
    host = @hostExtractor.exec(handshakeData.headers.referer)[0]
    key = handshakeData.query.key

    Account.with(@db).check_by_key_and_connect_host key, host, {
      on_accepted: (account) =>
        account.connected_host = host
        handshakeData.account = account
        callback(null, true)

      on_rejected: =>
        callback("Host #{host} with key #{key} not authorized!", false)
    }

module.exports = AuthenticationHandler
