#!/usr/bin/env coffee

# clear terminal
#process.stdout.write '\u001B[2J\u001B[0;0f'

config = require './config'
tapas = do require('tapas')(config.tapas).app

try
    require('./app.local') tapas
catch e
    console.log ''

tapas.autodiscover "./controllers"

do tapas.run
