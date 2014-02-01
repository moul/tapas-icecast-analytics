#!/usr/bin/env coffee

console.log process.argv

if process.argv.length <= 2
   console.log "Usage: ... http://admin:pass@host:8000/ http://admin:pass@host2:8000"
   process.exit 1

fs = require 'fs'
config = process.env[if process.platform == 'win32' then 'USERPROFILE' else 'HOME'] + '/.icecast-servers.json'

fs.writeFile config, JSON.stringify(process.argv[2...]), (err) ->
  if err
    console.log err
  else
    require './app'
