// Generated by CoffeeScript 1.3.1
(function() {
  var Account, HashLib;

  HashLib = require("hashlib");

  Account = {
    "with": function(db) {
      this.db = db;
      return this;
    },
    create: function(email, hosts) {
      var created_at, key;
      created_at = new Date().getTime();
      key = this.generate_key("" + email + "|" + created_at);
      return this.db.accounts.save({
        key: key,
        email: email,
        hosts: hosts,
        created_at: created_at
      });
    },
    generate_key: function(string) {
      return HashLib.sha1(string).toUpperCase();
    },
    find: function(query, callback) {
      var _this = this;
      return this.db.accounts.find(query).toArray(function(err, accounts) {
        return callback(accounts);
      });
    },
    check_by_key_and_connect_host: function(key, connected_host, callbacks) {
      var _this = this;
      return this.find({
        key: key,
        hosts: connected_host
      }, function(accounts) {
        if (accounts.length === 1) {
          return callbacks.on_accepted(accounts[0]);
        } else {
          return callbacks.on_rejected();
        }
      });
    }
  };

  module.exports = Account;

}).call(this);
