(function() {
  var RedisStore, Users, World, app, cfg, express, http, init, io, load, sys, winston;
  http = require('http');
  express = require('express');
  RedisStore = (require('connect-redis'))(express);
  sys = require('sys');
  cfg = require('./config/config.js');
  init = require('./controllers/utils/init.js');
  winston = require('winston');
  global.logger = new winston.Logger({
    transports: [
      new winston.transports.Console({
        level: 'debug',
        colorize: true
      })
    ]
  });
  app = express.createServer();
  io = (require('socket.io')).listen(app);
  app.configure(function() {
    app.set('views', __dirname + '/views');
    app.set('view engine', 'jade');
    app.register('.html', require('jade'));
    app.use(express.methodOverride());
    app.use(express.bodyParser());
    app.use(express.cookieParser());
    app.use(express.session({
      secret: cfg.SESSION_SECRET,
      store: new RedisStore
    }));
    app.use(app.router);
    return app.use(express.static(__dirname + '/public'));
  });
  app.dynamicHelpers({
    session: function(req, res) {
      return req.session;
    }
  });
  global.db = require('./models/db').db;
  /* Initialize controllers */
  Users = (require('./controllers/user.js')).Users;
  World = (require('./world.js')).World;
  /* Start Route Handling */
  app.get('/', function(req, res) {
    logger.debug(typeof world);
    if (typeof world === 'undefined') {
      logger.log('Game has not started yet.');
      load();
      return res.redirect('/');
    } else {
      return res.render('game', {});
    }
    /* Handle logins
    if req.session.auth == 1
      # User is authenticated
      res.send 'done'
    else
      res.send "You are not logged in. <A HREF='/login'>Click here</A> to login"
    */
  });
  /* Start a new game! */
  app.get('/start', function(req, res) {
    world.start();
    return res.redirect('/');
  });
  app.get('/end', function(req, res) {
    return world.destroy();
  });
  app.get('/register/:id/:name', function(req, res) {
    var user;
    console.log('TODO - Render registration page and ask for username');
    user = new Users;
    return user.addUser(req.params.id, req.params.name, function(json) {
      return console.log('Adding user: ' + req.params.id, req.params.name);
    });
  });
  app.get('/users', function(req, res) {
    var user;
    user = new Users;
    return user.get(null, function(json) {
      return res.send(json);
    });
  });
  app.get('/users/:id', function(req, res) {
    var callback, user;
    callback = '';
    user = new Users;
    return user.get(req.params.id, function(json) {
      return res.send(json);
    });
  });
  app.get('/login', function(req, res) {
    if (req.session.auth === 1) {
      return res.redirect('/');
    } else {
      logger.info('User logged in.');
      req.session.id = 0;
      req.session.name = 'verb';
      req.session.auth = 1;
      res.redirect('/');
      return logger.warning('TODO - Render Login page and ask for username');
    }
  });
  app.get('/logout', function(req, res) {
    logger.info('--- LOGOUT ---');
    logger.info(req.session);
    req.session.destroy();
    return res.redirect('/');
  });
  load = function() {
    /* Spawn the world!! */    var world;
    logger.info('Spawning New Game');
    world = new World(app);
    global.world = world;
    return world.emit('load');
  };
  app.listen(process.env.PORT || 3000);
  /* Socket.io Stuff */
  io.sockets.on('connection', function(socket) {
    socket.emit('test', {
      hello: 'world'
    });
    return socket.on('test event', function(data) {
      return logger.debug(data);
    });
  });
  /* Socket/World Event Listners */
}).call(this);
