{spawn, exec} = require 'child_process'

task 'dev', 'run dev mode', ->
    nodedev = spawn 'node-dev', ['app.coffee']
    nodedev.stdout.on 'data', (data) -> console.log data.toString().trim()
    nodedev.stderr.on 'data', (data) -> console.log data.toString().trim()

task 'run', 'run in production mode', ->
    env = process.env
    env['NODE_ENV'] = 'production'
    coffee = spawn 'coffee', ['app.coffee'], { env: env }
    coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
    #coffee.stderr.on 'data', (data) -> console.log data.toString().trim()
