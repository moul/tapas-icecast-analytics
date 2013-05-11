url =     require 'url'
config =  require '../../config'
{Admin} = require 'icecast-admin'

lynx = require 'lynx'
metrics = new lynx config.statsd.host, config.statsd.port
metrics.increment "#{config.statsd.prefix}.run"

admins_key = []
admins = {}
tree = {}

isNumber = (n) -> return !isNaN(parseFloat(n)) && isFinite(n)

next_i = 0
updateNextAdmin = ->
  metrics.increment "#{config.statsd.prefix}.updateNextAdmin"
  clients = exports.tapas.io.rooms['']?.length || 0
  active = clients > 0
  admin_key = admins_key[next_i++ % admins_key.length]
  admin = admins[admin_key]
  updateAdmin admin, active

exports.open = (app, tapas) ->
  exports.tapas = tapas

  tapas.io.on 'connection', (socket) ->
    metrics.increment "#{config.statsd.prefix}.io.on.connection"
    console.log 'new io client'
    socket.on 'getTree', (fn = null) ->
      metrics.increment "#{config.statsd.prefix}.io.on.getTree"
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
    metric_name = "#{config.statsd.prefix}.icecast.#{admin.id.replace(/[^a-zA-Z0-9]/g,'-')}"
    admin.stats (err, data) ->
      if err
        console.log "Error with #{admin.id}:", err
        metrics.increment "#{metric_name}.error"
      else
        metrics.increment "#{metric_name}.success"
        for source in data.icestats.source
          server_name = source['server_name'][0]
          server_name_clean = server_name.replace(/[^a-zA-Z0-9]/g,'-')
          metrics.increment "#{metric_name}.source.#{server_name_clean}.success"
          branch = admin.branch[server_name] =
            id: admin.id
            server_name: server_name
          for key in ['listeners', 'slow_listeners', 'total_bytes_read', 'total_bytes_sent', 'title', 'bitrate', 'max_listeners']
            branch[key] = source[key]?[0]
            if isNumber branch[key]
              metrics.gauge "#{metric_name}.source.#{server_name_clean}.data.#{key}", parseFloat(branch[key])
              #console.log "#{metric_name}.source.#{server_name_clean}.data.#{key}", parseFloat(branch[key])
        exports.tapas.io.sockets.emit 'updateServer', admin.branch
      if not firstTime
        setTimeout updateNextAdmin, config.timer
  else
    if not firstTime
      setTimeout updateNextAdmin, config.timer

exports.index = (req, res) ->
  metrics.increment "#{config.statsd.prefix}.page.index"
  mounts = req.query.mount?.split(',') || []
  for mount in mounts
    metrics.increment "#{config.statsd.prefix}.page.index_with_mount.#{mount}"
  res.render 'analytics',
    mounts: mounts
