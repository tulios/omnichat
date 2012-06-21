(function() {
  var Account, AuthenticationHandler;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Account = require('./../models/account');
  AuthenticationHandler = (function() {
    function AuthenticationHandler(db) {
      this.db = db;
      this.hostExtractor = new RegExp("http://[^/]+");
      this.pathExtractor = new RegExp("[^?]+");
    }
    AuthenticationHandler.prototype.handle = function(handshakeData, callback) {
      var host, key, path, referer;
      referer = handshakeData.headers.referer;
      host = this.hostExtractor.exec(referer)[0];
      path = this.pathExtractor.exec(referer)[0].replace(host, "");
      key = handshakeData.query.key;
      return Account["with"](this.db).check_by_key_and_connect_host(key, host, {
        on_accepted: __bind(function(account) {
          account.connected_host = host;
          account.connected_path = path;
          handshakeData.account = account;
          return callback(null, true);
        }, this),
        on_rejected: __bind(function() {
          return callback("Host " + host + " with key " + key + " not authorized!", false);
        }, this)
      });
    };
    return AuthenticationHandler;
  })();
  module.exports = AuthenticationHandler;
}).call(this);
