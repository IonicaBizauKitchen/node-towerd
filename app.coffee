http = require 'http'
express = require 'express'
RedisStore = (require 'connect-redis')(express)
sys = require 'sys'
mongoose = require 'mongoose'
gzippo = require 'gzippo'
cfg = require './config/config.js'    # contains API keys, etc.


app = express.createServer()

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.register '.html', require 'jade'
  app.use express.methodOverride()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session { secret: cfg.SESSION_SECRET, store: new RedisStore}
  app.use app.router
  app.use(gzippo.staticGzip(__dirname + '/public'));  
  
mongoose.connection.on 'open', ->
  console.log 'Mongo is connected!'
  
app.dynamicHelpers { session: (req, res) -> req.session }

### Initialize controllers ###
Game = (require './controllers/game.js').Game
Users = (require './controllers/user.js').Users
# Mobs = (require './controllers/mobs.js').Mobs

### Start Route Handling ###
 
# Home Page
app.get '/', (req, res) ->  
  if req.session.auth == 1
    # User is authenticated
    console.log 'Spawning New Game'
    newgame = new Game
    
    res.send 'done'
  else
    res.send "You are not logged in. <A HREF='/login'>Click here</A> to login"

app.get '/register/:id/:name', (req, res) ->
  # Allow a user to register
  console.log 'TODO - Render registration page and ask for username'
  user = new Users
  user.addUser req.params.id, req.params.name, (json) ->
    console.log 'Adding user: ' + req.params.id, req.params.name

# List All Users
app.get '/users', (req, res) ->
  user = new Users
  user.get null, (json) ->
    console.log 'json: ' + json
    res.send json
    # res.render 'users', { json: json }

# Single User Profile
app.get '/users/:id', (req, res) ->
  callback = ''
  user = new Users
  user.get req.params.id, (json) ->
    res.send json
    # res.render 'users/singleUser', { json: json }

app.get '/login', (req, res) ->
  if req.session.auth == 1
    # User is already auth'd
    res.redirect '/'
  else
    console.log 'User logged in.'
    req.session.id = 0
    req.session.name = 'verb'
    req.session.auth = 1
    res.redirect '/'
    console.log 'TODO - Render Login page and ask for username'
  
app.get '/logout', (req, res) ->
  console.log '--- LOGOUT ---'
  console.log req.session
  console.log '--- LOGOUT ---'
  req.session.destroy()
  res.redirect '/'

app.listen process.env.PORT or 3000 