
express = require 'express'
app = express()
server = require('http').Server app
io = require('socket.io') server
server.listen process.env.PORT or 9998
app.use express.static 'public'
app.set 'views', './public'
app.set 'view engine', 'jade'
app.get '/', (req, res) -> res.render 'public'
