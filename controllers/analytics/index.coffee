url =     require 'url'
config =  require '../../config'
{Admin} = require 'icecast-admin'

admins_key = []
admins = {}
tree = {}

next_i = 0
updateNextAdmin = ->
  clients = exports.tapas.io.rooms['']?.length || 0
  active = clients > 0
  admin_key = admins_key[next_i++ % admins_key.length]
  admin = admins[admin_key]
  updateAdmin admin, active

exports.open = (app, tapas) ->
  exports.tapas = tapas

  tapas.io.on 'connection', (socket) ->
    console.log 'new io client'
    socket.on 'getTree', (fn = null) ->
      console.log 'getTree'
      fn tree

  for group, servers of config.icecast_servers
    tree[group] = {}
    for server in servers
      id = url.parse(server).host
      branch = tree[group][id] = {}
      admins_key.push id
      admin = admins[id] = new Admin
        url: server
      admin.id = id
      admin.branch = branch
      updateAdmin admin, true, true
  do updateNextAdmin

updateAdmin = (admin, active = true, firstTime = false) ->
  if active
    console.log "updateAdmin #{admin.id}"
    admin.stats (err, data) ->
      if err
        console.log "Error with #{admin.id}:", err
      else
        for source in data.icestats.source
          server_name = source['server_name'][0]
          branch = admin.branch[server_name] =
            id: admin.id
            server_name: server_name
          for key in ['listeners', 'slow_listeners', 'total_bytes_read', 'total_bytes_sent', 'title', 'bitrate', 'max_listeners']
            branch[key] = source[key]?[0]
        exports.tapas.io.sockets.emit 'updateServer', admin.branch
      if not firstTime
        setTimeout updateNextAdmin, config.timer
  else
    if not firstTime
      setTimeout updateNextAdmin, config.timer

exports.index = (req, res) ->
  mounts = req.query.mount?.split(',') || []
  res.render 'analytics',
    mounts: mounts
