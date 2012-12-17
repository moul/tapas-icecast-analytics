#!/usr/bin/env coffee

# clear terminal
#process.stdout.write '\u001B[2J\u001B[0;0f'

config = require './config'
tapas = do require('tapas')(config.tapas).app
tapas.autodiscover "./controllers"

do tapas.run
