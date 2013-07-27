express = require "express"
app = express()

server = require("http").createServer(app)

# require our session manager
SessionManager = require("../lib")(express)

console.log new SessionManager()
# require our testing tools
expect = require "expect.js"
request = require "request"

# build bs application
app.set "port", 1338

# build out test object
sessOpts =
  stale: "4d"
  expres: "5d"

# build out our middleware for sessions
app.use express.session
  secret: "test"
  cookie: 
    httpOnly: true
    maxAge: 1000 * 60 * 60 * 24
  store: new SessionManager sessOpts


# build test routes
app.get "/", (req, res) ->
  res.send "tested making a session store.."

describe "fire up our server!", ->
  it "should give us a console.log when our server has started..", (done) ->

    expect(app.get("port")).not.to.be(null)

    server.listen app.get("port"), ->
      console.log "listening on port #{app.get("port")}"
      done()

describe "validate session existence", ->

  it "should give us a session!", (done) ->

    request "http://localhost:1338", (e, r, b) ->
      expect(e).to.be(null)
      done()