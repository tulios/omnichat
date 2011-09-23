Account = require './../models/account'

class AuthenticationHandler
  constructor: (db) ->
    @db = db
    @hostExtractor = new RegExp("http://[^/]+")
    @pathExtractor = new RegExp("[^?]+")

  handle: (handshakeData, callback) ->
    referer = handshakeData.headers.referer
    host = @hostExtractor.exec(referer)[0]
    path = @pathExtractor.exec(referer)[0].replace(host, "")

    key = handshakeData.query.key

    Account.with(@db).check_by_key_and_connect_host key, host, {
      on_accepted: (account) =>
        account.connected_host = host
        account.connected_path = path
        handshakeData.account = account
        callback(null, true)

      on_rejected: =>
        callback("Host #{host} with key #{key} not authorized!", false)
    }

module.exports = AuthenticationHandler
