(function() {
  var Account;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Account = {
    "with": function(db) {
      this.db = db;
      return this;
    },
    create: function(email, hosts) {
      return this.db.accounts.save({
        key: key,
        email: email,
        hosts: hosts,
        created_at: new Date().getTime()
      });
    },
    find: function(query, callback) {
      return this.db.accounts.find(query).toArray(__bind(function(err, accounts) {
        return callback(accounts);
      }, this));
    },
    check_by_key_and_connect_host: function(key, connected_host, callbacks) {
      return this.find({
        key: key,
        hosts: connected_host
      }, __bind(function(accounts) {
        if (accounts.length === 1) {
          return callbacks.on_accepted(accounts[0]);
        } else {
          return callbacks.on_rejected();
        }
      }, this));
    }
  };
  module.exports = Account;
}).call(this);
