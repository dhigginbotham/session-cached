### session manager ###

# require modules
_ = require "underscore"
MongoClient = require("mongodb").MongoClient
ms = require "ms"

module.exports = (connect) ->

  SessionManager = (opts, fn) ->
    
    # this will handle all of the `connect` & `express` handling for session support through mongodb
    @path = "mongodb://127.0.0.1:27017"

    # define collection name
    @collection = "session"

    # expires is an absolute, don't pass go -- delete session event
    @expires = "1d"

    # stale will refresh the db with a fresh copy of your session
    @stale = "23h"

    # do an extend, get some defaults
    if opts? then _.extend @, opts

    # maintain our scope
    self = @

    # get a connection we can play with in our session
    MongoClient.connect @path + "/" + @collection, (err, db) ->
      return if err? then fn err, null

      self.db = db

      return if db? then fn null, self else fn null, null

    @

  # inheriting settings from `connect` / `express` session store
  SessionManager.prototype.__proto__ = connect.session.Store.prototype;

  # overwrite fns for session support
  SessionManager::get = (sid, fn) ->
    this.db.findOne {sid: sid}, (err, sess) ->
      return if err? then fn err, null
      return if not sess? then fn null, null else fn null, sess.sess

  SessionManager::set = (sid, sess, fn) ->
    this.db.update {sid: sid}, {sid: sid, sess: sess}, {multi: false, upsert: true}, (err) ->
      return fn err

  SessionManager::destroy = (sid, fn) ->
    this.db.remove {sid: sid}, {multi: false}, (err) ->
      return fn err

  SessionManager