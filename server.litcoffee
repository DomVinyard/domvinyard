


# First we have to get the website up and running and listening out for new users that are arriving. If no users are arriving we will just sit and wait. We will not grow bored or lonely or impatient.

    express = require 'express'
    app = express()
    server = require('http').Server app
    server.listen (process.env.PORT or 9998)    # Port 9998 is like 
                                               # our room number.



# When A new user arrives, we need to send them some info about Dom.

    app.set 'view engine', 'pug'
    app.use express.static 'resources'
    app.set 'views', './'
    app.get '/', (req, res) -> res.render 'dom'

    
