/* session manager*/


(function() {
  var MongoClient, ms, _;

  _ = require("underscore");

  MongoClient = require("mongodb").MongoClient;

  ms = require("ms");

  module.exports = function(connect) {
    var SessionManager;
    SessionManager = function(opts, fn) {
      var self;
      this.path = "mongodb://127.0.0.1:27017";
      this.collection = "session";
      this.expires = "1d";
      this.stale = "23h";
      if (opts != null) {
        _.extend(this, opts);
      }
      self = this;
      MongoClient.connect(this.path + "/" + this.collection, function(err, db) {
        if (err != null) {
          return fn(err, null);
        }
        self.db = db;
        if (db != null) {
          return fn(null, self);
        } else {
          return fn(null, null);
        }
      });
      return this;
    };
    SessionManager.prototype.__proto__ = connect.session.Store.prototype;
    SessionManager.prototype.get = function(sid, fn) {
      return this.db.findOne({
        sid: sid
      }, function(err, sess) {
        if (err != null) {
          return fn(err, null);
        }
        if (sess == null) {
          return fn(null, null);
        } else {
          return fn(null, sess.sess);
        }
      });
    };
    SessionManager.prototype.set = function(sid, sess, fn) {
      return this.db.update({
        sid: sid
      }, {
        sid: sid,
        sess: sess
      }, {
        multi: false,
        upsert: true
      }, function(err) {
        return fn(err);
      });
    };
    SessionManager.prototype.destroy = function(sid, fn) {
      return this.db.remove({
        sid: sid
      }, {
        multi: false
      }, function(err) {
        return fn(err);
      });
    };
    return SessionManager;
  };

}).call(this);
