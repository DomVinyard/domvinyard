
db_name = 'heroku_12fqdp0h'
db_url = 'ds051615.mongolab.com:51615'
mongoPath = "mongodb://dom:LeM-YVf-6Rr-MH7@#{db_url}/#{db_name}"
MongoClient = require('mongodb').MongoClient
MongoClient.connect mongoPath, (error, db) ->
  return process.exit() if error
  mongo = db.collection 'sensibles'
  mongo.findOne { _id: 'sensibles' }, (error, record) =>
    clicks = record.clicks
    express = require 'express'
    app = express()
    server = require('http').Server app
    io = require('socket.io') server
    server.listen process.env.PORT or 9998
    app.use express.static 'public'
    app.set 'views', './public'
    app.set 'view engine', 'jade'
    app.get '/', (req, res) -> res.render 'app', { clicks: clicks }
    io.on 'connection', (socket) ->
      socket.lastRequest = new Date()
      socket.on 'sensible', (code) ->
        rate = (new Date()) - socket.lastRequest
        socket.lastRequest = new Date()
        return if rate < 1500
        clicks = clicks + 1
        mongo.update { _id: 'sensibles' }, { clicks: clicks }, {upsert: yes}
        io.emit 'sensible', { code: code, clicks: clicks }
